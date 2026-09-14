RSpec.describe OpenAI::Client do
  describe "#agents.environments" do
    let(:client) { OpenAI::Client.new }
    let(:cassette) { "agents environments" }

    it "retrieves a hosted environment and manages its files" do
      VCR.use_cassette(cassette) do
        session = client.agents.sessions.create(
          parameters: { environment: { type: "openai_hosted" },
                        agent: { model: AgentsHelpers::AGENTS_MODEL } }
        )
        environment_id = session["environment"]["id"]

        environment = wait_for_connected_environment(client, environment_id)
        expect(environment["object"]).to eq("agent.environment")
        expect(environment["status"]).to eq("connected")

        file = client.agents.environments.files.create(
          environment_id: environment_id,
          parameters: { type: "inline", path: "/workspace/hello.txt",
                        data: Base64.strict_encode64("hello") }
        )
        expect(file["object"]).to eq("agent.environment.file")
        expect(file["path"]).to eq("/workspace/hello.txt")

        listing = client.agents.environments.files.list(environment_id: environment_id,
                                                        parameters: { limit: 5 })
        expect(listing["data"].map { |f| f["path"] }).to include("/workspace/hello.txt")

        client.agents.sessions.delete(id: session["id"])
      end
    end
  end
end
