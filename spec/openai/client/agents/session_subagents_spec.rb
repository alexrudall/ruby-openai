RSpec.describe OpenAI::Client do
  describe "#agents.sessions.subagents" do
    let(:client) { OpenAI::Client.new }
    let(:base) { "https://api.openai.com/v1/agents/sessions/sess_x/subagents" }
    let(:session_id) do
      VCR.use_cassette("#{cassette} setup") do
        client.agents.sessions.create(
          parameters: {
            environment: { type: "none" },
            agent: { model: AgentsHelpers::AGENTS_MODEL, instructions: "Reply with one word." },
            input: "Say hi"
          }
        )["id"]
      end
    end

    describe "#list" do
      let(:cassette) { "agents session subagents list" }

      it "lists subagents" do
        VCR.use_cassette(cassette) do
          response = client.agents.sessions.subagents.list(session_id: session_id)
          expect(response["object"]).to eq("list")
          expect(response["data"]).to eq([])
        end
      end
    end

    describe "#retrieve" do
      it "requests the subagent" do
        stub = stub_request(:get, "#{base}/sub_1").to_return(status: 200,
                                                             body: { id: "sub_1" }.to_json)
        response = client.agents.sessions.subagents.retrieve(session_id: "sess_x", id: "sub_1")
        expect(stub).to have_been_requested
        expect(response["id"]).to eq("sub_1")
      end
    end

    describe "#items.list" do
      it "requests the subagent items" do
        stub = stub_request(:get, "#{base}/sub_1/items?limit=2")
               .to_return(status: 200, body: { object: "list", data: [] }.to_json)
        client.agents.sessions.subagents.items.list(session_id: "sess_x", subagent_id: "sub_1",
                                                    parameters: { limit: 2 })
        expect(stub).to have_been_requested
      end
    end

    describe "#turns" do
      it "lists and retrieves subagent turns" do
        list = stub_request(:get, "#{base}/sub_1/turns")
               .to_return(status: 200, body: { object: "list", data: [] }.to_json)
        get = stub_request(:get, "#{base}/sub_1/turns/turn_1")
              .to_return(status: 200, body: { id: "turn_1" }.to_json)
        client.agents.sessions.subagents.turns.list(session_id: "sess_x", subagent_id: "sub_1")
        client.agents.sessions.subagents.turns.retrieve(
          session_id: "sess_x", subagent_id: "sub_1", id: "turn_1"
        )
        expect(list).to have_been_requested
        expect(get).to have_been_requested
      end

      it "lists subagent turn items" do
        stub = stub_request(:get, "#{base}/sub_1/turns/turn_1/items")
               .to_return(status: 200, body: { object: "list", data: [] }.to_json)
        client.agents.sessions.subagents.turns.items.list(
          session_id: "sess_x", subagent_id: "sub_1", turn_id: "turn_1"
        )
        expect(stub).to have_been_requested
      end
    end
  end
end
