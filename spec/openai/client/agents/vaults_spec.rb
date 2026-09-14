RSpec.describe OpenAI::Client do
  describe "#agents.vaults" do
    let(:client) { OpenAI::Client.new }
    let(:vaults) { client.agents.vaults }
    let(:vault_id) do
      VCR.use_cassette("#{cassette} setup") do
        vaults.create(parameters: { name: "ruby-openai spec" })["id"]
      end
    end

    describe "#create" do
      let(:cassette) { "agents vaults create" }

      it "creates a vault" do
        VCR.use_cassette(cassette) do
          response = vaults.create(parameters: { name: "ruby-openai spec",
                                                 metadata: { env: "spec" } })
          expect(response["object"]).to eq("vault")
          expect(response["metadata"]).to eq({ "env" => "spec" })
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "agents vaults retrieve" }

      it "retrieves the vault" do
        VCR.use_cassette(cassette) do
          expect(vaults.retrieve(id: vault_id)["id"]).to eq(vault_id)
        end
      end
    end

    describe "#list" do
      let(:cassette) { "agents vaults list" }

      it "lists vaults" do
        VCR.use_cassette(cassette) do
          vault_id
          response = vaults.list(parameters: { limit: 5 })
          expect(response["object"]).to eq("list")
          expect(response["data"]).to be_an(Array)
        end
      end
    end

    describe "#delete" do
      let(:cassette) { "agents vaults delete" }

      it "deletes the vault" do
        VCR.use_cassette(cassette) do
          expect(vaults.delete(id: vault_id)["deleted"]).to be(true)
        end
      end
    end
  end
end
