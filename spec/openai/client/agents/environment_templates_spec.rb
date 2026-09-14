RSpec.describe OpenAI::Client do
  describe "#agents.environments.templates" do
    let(:client) { OpenAI::Client.new }
    let(:templates) { client.agents.environments.templates }
    let(:template_id) do
      VCR.use_cassette("#{cassette} setup") do
        templates.create(parameters: { name: "ruby-openai spec" })["id"]
      end
    end

    describe "#create" do
      let(:cassette) { "agents environment templates create" }

      it "creates a template" do
        VCR.use_cassette(cassette) do
          response = templates.create(
            parameters: { name: "ruby-openai spec", packages: { python: ["requests"] } }
          )
          expect(response["object"]).to eq("agent.environment.template")
          expect(response["packages"]["python"]).to eq(["requests"])
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "agents environment templates retrieve" }

      it "retrieves the template" do
        VCR.use_cassette(cassette) do
          expect(templates.retrieve(id: template_id)["id"]).to eq(template_id)
        end
      end
    end

    describe "#update" do
      let(:cassette) { "agents environment templates update" }

      it "updates the template" do
        VCR.use_cassette(cassette) do
          expect(templates.update(id: template_id,
                                  parameters: { name: "renamed" })["name"]).to eq("renamed")
        end
      end
    end

    describe "#list" do
      let(:cassette) { "agents environment templates list" }

      it "lists templates" do
        VCR.use_cassette(cassette) do
          template_id
          response = templates.list(parameters: { limit: 5 })
          expect(response["object"]).to eq("list")
          expect(response["data"]).to be_an(Array)
        end
      end
    end

    describe "#delete" do
      let(:cassette) { "agents environment templates delete" }

      it "deletes the template" do
        VCR.use_cassette(cassette) do
          expect(templates.delete(id: template_id)["deleted"]).to be(true)
        end
      end
    end
  end
end
