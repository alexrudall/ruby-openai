RSpec.describe OpenAI::Client do
  describe "#agents.sessions.items" do
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
      let(:cassette) { "agents session items list" }

      it "lists the session items" do
        VCR.use_cassette(cassette) do
          response = client.agents.sessions.items.list(session_id: session_id,
                                                       parameters: { limit: 10 })
          expect(response["object"]).to eq("list")
          roles = response["data"].map { |item| item["role"] }
          expect(roles).to include("user", "assistant")
        end
      end
    end
  end
end
