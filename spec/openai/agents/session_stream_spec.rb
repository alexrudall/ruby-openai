RSpec.describe OpenAI::Agents::SessionStream do
  let(:client) { OpenAI::Client.new }
  let(:sessions) { client.agents.sessions }
  let(:session_id) { "sess_094226705b0fa5b3006aa7d41719448191bb59885485a89279" }
  let(:base) { "https://api.openai.com/v1/agents/sessions/#{session_id}" }
  let(:status) { "idle" }
  let(:sse) { File.read(File.join(RSPEC_ROOT, "fixtures", "files", "agent_session_stream.sse")) }
  let(:events_posts) { [] }

  before do
    stub_request(:get, base).to_return(status: 200,
                                       body: {
                                         id: session_id, status: status
                                       }.to_json)
    stub_request(:get, "#{base}/events")
      .to_return(status: 200, body: sse, headers: { "Content-Type" => "text/event-stream" })
    stub_request(:post, "#{base}/events").to_return do |request|
      events_posts << [JSON.parse(request.body), request.headers["Idempotency-Key"]]
      { status: 202, body: "" }
    end
  end

  describe "#run" do
    it "submits the input, yields every event and stops at idle" do
      types = []
      result = sessions.stream(id: session_id, input: "What is the weather in Paris?") do |_e, type|
        types << type
      end

      expect(result).to be_nil
      expect(types.first).to eq("agent.session.turn.created")
      expect(types.last).to eq("agent.session.idle")
      expect(types).to include("agent.session.turn.completed")

      input_event = events_posts.first.first["events"].first
      expect(input_event["type"]).to eq("agent.session.input.message")
      text = input_event["input"].first["content"].first["text"]
      expect(text).to eq("What is the weather in Paris?")
    end

    it "uses the given idempotency key for the input submission" do
      sessions.stream(id: session_id, input: "hi", idempotency_key: "my-key") { |_e, _t| nil }
      expect(events_posts.first.last).to eq("my-key")
    end

    it "accepts an array of input messages" do
      messages = [{ role: "user", content: [{ type: "input_text", text: "hi" }] }]
      sessions.stream(id: session_id, input: messages) { |_e, _t| nil }
      expect(events_posts.first.first["events"].first["input"]).to eq(JSON.parse(messages.to_json))
    end

    it "invokes a registered tool handler and submits its result" do
      received = nil
      handler = lambda do |args|
        received = args
        { temperature: 21, unit: "C" }
      end

      sessions.stream(id: session_id, input: "weather?",
                      tool_handlers: { "get_weather" => handler }) do
        nil
      end

      expect(received).to eq({ "city" => "Paris" })
      expect(events_posts.length).to eq(2)
      tool_result, key = events_posts.last
      event = tool_result["events"].first
      expect(event["type"]).to eq("agent.session.input.tool_result")
      expect(event["call_id"]).to eq("call_l44NaKe90dlGhLIxdV6EaATw")
      expect(event["success"]).to be(true)
      expect(JSON.parse(event["output"])).to eq({ "temperature" => 21, "unit" => "C" })
      expect(key).not_to be_nil
    end

    it "accepts content part arrays and rejects other arrays" do
      handlers = { "get_weather" => ->(_a) { [{ type: "input_text", text: "21C" }] } }
      sessions.stream(id: session_id, input: "weather?", tool_handlers: handlers) { |_e, _t| nil }
      event = events_posts.last.first["events"].first
      expect(event["success"]).to be(true)
      expect(event["output"]).to eq([{ "type" => "input_text", "text" => "21C" }])

      events_posts.clear
      handlers = { "get_weather" => ->(_a) { [1, 2] } }
      sessions.stream(id: session_id, input: "weather?", tool_handlers: handlers) { |_e, _t| nil }
      expect(events_posts.last.first["events"].first["success"]).to be(false)
    end

    it "submits a failure when the handler raises" do
      handler = ->(_args) { raise "boom" }
      sessions.stream(id: session_id, input: "weather?",
                      tool_handlers: { "get_weather" => handler }) do
        nil
      end

      event = events_posts.last.first["events"].first
      expect(event["success"]).to be(false)
      expect(event["error"]).to eq("Tool handler failed.")
      expect(event).not_to have_key("output")
    end

    it "leaves unregistered tools to the caller" do
      handlers = { "other" => ->(_a) { "x" } }
      sessions.stream(id: session_id, input: "weather?", tool_handlers: handlers) { |_e, _t| nil }
      expect(events_posts.length).to eq(1)
    end

    it "retries a tool result rejected as an unknown pending call" do
      calls = 0
      stub_request(:post, "#{base}/events").to_return do |request|
        events = JSON.parse(request.body)["events"]
        if events.first["type"] == "agent.session.input.tool_result" && (calls += 1) == 1
          message = "Unknown pending tool call: call_l44NaKe90dlGhLIxdV6EaATw"
          { status: 400, body: { error: { message: message } }.to_json,
            headers: { "Content-Type" => "application/json" } }
        else
          { status: 202, body: "" }
        end
      end
      allow_any_instance_of(OpenAI::Agents::ToolCall).to receive(:sleep)

      handlers = { "get_weather" => ->(_a) { "ok" } }
      sessions.stream(id: session_id, input: "weather?", tool_handlers: handlers) { |_e, _t| nil }
      expect(calls).to eq(2)
    end

    context "when the session is not idle" do
      let(:status) { "in_progress" }

      it "raises an ArgumentError" do
        expect { sessions.stream(id: session_id, input: "hi") { |_e, _t| nil } }
          .to raise_error(ArgumentError, /requires an idle session/)
      end
    end

    it "raises an ArgumentError for empty input" do
      expect { sessions.stream(id: session_id, input: "") }
        .to raise_error(ArgumentError, /must not be empty/)
      expect { sessions.stream(id: session_id, input: []) }
        .to raise_error(ArgumentError, /must not be empty/)
    end

    context "when the stream ends before the turn finishes" do
      let(:sse) do
        sse_body([["agent.session.turn.created", { "type" => "agent.session.turn.created",
                                                   "event_id" => "evt_1", "turn_id" => "turn_1" }]])
      end

      it "raises an OpenAI::Error" do
        expect { sessions.stream(id: session_id, input: "hi") { |_e, _t| nil } }
          .to raise_error(OpenAI::Error, /ended before the turn finished/)
      end
    end
  end
end
