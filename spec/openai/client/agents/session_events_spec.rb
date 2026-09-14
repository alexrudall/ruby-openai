RSpec.describe OpenAI::Client do
  describe "#agents.sessions.events" do
    let(:client) { OpenAI::Client.new }
    let(:session_id) do
      VCR.use_cassette("#{cassette} setup") do
        id = client.agents.sessions.create(
          parameters: {
            environment: { type: "none" },
            agent: { model: AgentsHelpers::AGENTS_MODEL, instructions: "Reply with one word." },
            input: "Say hi"
          }
        )["id"]
        wait_for_idle_session(client, id)
        id
      end
    end

    describe "#create" do
      let(:cassette) { "agents session events create" }

      it "submits a message event and runs a turn" do
        VCR.use_cassette(cassette) do
          client.agents.sessions.events.create(
            session_id: session_id,
            idempotency_key: "ruby-openai-spec-events-create",
            parameters: {
              events: [
                {
                  type: "agent.session.input.message",
                  input: [{ role: "user", content: [{ type: "input_text", text: "Say bye" }] }]
                }
              ]
            }
          )
          turns = wait_for_turn_count(client, session_id, 2)
          expect(turns["data"].length).to eq(2)
          expect(wait_for_idle_session(client, session_id)["status"]).to eq("idle")
        end
      end

      it "sends the Idempotency-Key header" do
        stub = stub_request(:post, "https://api.openai.com/v1/agents/sessions/sess_x/events")
               .with(headers: { "Idempotency-Key" => "key-1", "OpenAI-Beta" => "agents=v1" })
               .to_return(status: 200, body: "")
        client.agents.sessions.events.create(
          session_id: "sess_x",
          idempotency_key: "key-1",
          parameters: { events: [{ type: "agent.session.input.cancel" }] }
        )
        expect(stub).to have_been_requested
      end
    end

    describe "#stream" do
      let(:events) { [] }
      let(:body) do
        sse_body(
          [
            ["agent.session.turn.created",
             { "type" => "agent.session.turn.created", "turn_id" => "turn_1" }],
            ["agent.session.idle", { "type" => "agent.session.idle" }]
          ]
        )
      end

      before do
        stub_request(:get, "https://api.openai.com/v1/agents/sessions/sess_x/events")
          .with(headers: { "Accept" => "text/event-stream", "OpenAI-Beta" => "agents=v1" })
          .to_return(status: 200, body: body, headers: { "Content-Type" => "text/event-stream" })
      end

      it "yields each parsed event with its type" do
        client.agents.sessions.events.stream(
          session_id: "sess_x",
          stream: proc { |event, type| events << [type, event] }
        )
        expect(events.map(&:first)).to eq(["agent.session.turn.created", "agent.session.idle"])
        expect(events.first.last["turn_id"]).to eq("turn_1")
      end
    end
  end
end
