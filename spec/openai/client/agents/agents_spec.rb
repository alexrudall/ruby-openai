RSpec.describe OpenAI::Client do
  describe "#agents" do
    let(:client) { OpenAI::Client.new }
    let(:agent_id) do
      VCR.use_cassette("#{cassette} setup") do
        client.agents.create(parameters: { model: AgentsHelpers::AGENTS_MODEL,
                                           name: "ruby-openai spec" })["id"]
      end
    end

    describe "#create" do
      let(:cassette) { "agents create" }

      it "creates an agent" do
        VCR.use_cassette(cassette) do
          response = client.agents.create(
            parameters: {
              model: AgentsHelpers::AGENTS_MODEL,
              name: "ruby-openai spec",
              instructions: "You are a helpful assistant.",
              tools: [
                {
                  type: "function",
                  name: "get_weather",
                  description: "Get the weather for a city",
                  parameters: {
                    type: "object",
                    properties: { city: { type: "string" } },
                    required: ["city"]
                  }
                }
              ]
            }
          )
          expect(response["object"]).to eq("agent")
          expect(response["tools"].first["name"]).to eq("get_weather")
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "agents retrieve" }

      it "retrieves the agent" do
        VCR.use_cassette(cassette) do
          response = client.agents.retrieve(id: agent_id)
          expect(response["id"]).to eq(agent_id)
          expect(response["object"]).to eq("agent")
        end
      end
    end

    describe "#update" do
      let(:cassette) { "agents update" }

      it "updates the agent" do
        VCR.use_cassette(cassette) do
          response = client.agents.update(id: agent_id, parameters: { name: "renamed" })
          expect(response["name"]).to eq("renamed")
        end
      end
    end

    describe "#list" do
      let(:cassette) { "agents list" }

      it "lists agents" do
        VCR.use_cassette(cassette) do
          agent_id
          response = client.agents.list(parameters: { limit: 5 })
          expect(response["object"]).to eq("list")
          expect(response["data"]).to be_an(Array)
        end
      end
    end

    describe "#delete" do
      let(:cassette) { "agents delete" }

      it "deletes the agent" do
        VCR.use_cassette(cassette) do
          response = client.agents.delete(id: agent_id)
          expect(response["deleted"]).to be(true)
        end
      end
    end
  end
end
