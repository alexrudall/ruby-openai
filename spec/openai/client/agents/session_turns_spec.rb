RSpec.describe OpenAI::Client do
  describe "#agents.sessions.turns" do
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

    describe "#list" do
      let(:cassette) { "agents session turns list" }

      it "lists the session turns" do
        VCR.use_cassette(cassette) do
          response = client.agents.sessions.turns.list(session_id: session_id)
          expect(response["object"]).to eq("list")
          expect(response["data"].first["object"]).to eq("agent.session.turn")
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "agents session turns retrieve" }

      it "retrieves a turn" do
        VCR.use_cassette(cassette) do
          turn_id = client.agents.sessions.turns.list(session_id: session_id)["data"].first["id"]
          response = client.agents.sessions.turns.retrieve(session_id: session_id, id: turn_id)
          expect(response["id"]).to eq(turn_id)
          expect(response["session_id"]).to eq(session_id)
        end
      end
    end
  end
end
