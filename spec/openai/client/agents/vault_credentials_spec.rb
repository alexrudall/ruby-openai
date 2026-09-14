RSpec.describe OpenAI::Client do
  describe "#agents.vaults.credentials" do
    let(:client) { OpenAI::Client.new }
    let(:credentials) { client.agents.vaults.credentials }
    let(:auth) { { type: "static_bearer", token: "test-token", mcp_server_url: "https://example.com/mcp" } }
    let(:vault_id) do
      VCR.use_cassette("#{cassette} vault setup") do
        client.agents.vaults.create(parameters: { name: "ruby-openai spec" })["id"]
      end
    end
    let(:credential_id) do
      VCR.use_cassette("#{cassette} setup") do
        credentials.create(vault_id: vault_id, parameters: { name: "spec", auth: auth })["id"]
      end
    end

    describe "#create" do
      let(:cassette) { "agents vault credentials create" }

      it "creates a credential" do
        VCR.use_cassette(cassette) do
          response = credentials.create(vault_id: vault_id,
                                        parameters: {
                                          name: "spec", auth: auth
                                        })
          expect(response["object"]).to eq("vault.credential")
          expect(response["auth"]["type"]).to eq("static_bearer")
          expect(response["auth"]).not_to have_key("token")
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "agents vault credentials retrieve" }

      it "retrieves the credential" do
        VCR.use_cassette(cassette) do
          response = credentials.retrieve(vault_id: vault_id, id: credential_id)
          expect(response["id"]).to eq(credential_id)
        end
      end
    end

    describe "#update" do
      let(:cassette) { "agents vault credentials update" }

      it "rotates the credential auth" do
        VCR.use_cassette(cassette) do
          response = credentials.update(
            vault_id: vault_id,
            id: credential_id,
            parameters: { auth: { type: "static_bearer", token: "rotated-token" } }
          )
          expect(response["id"]).to eq(credential_id)
          expect(response["updated_at"]).to be >= response["created_at"]
        end
      end
    end

    describe "#list" do
      let(:cassette) { "agents vault credentials list" }

      it "lists credentials" do
        VCR.use_cassette(cassette) do
          credential_id
          response = credentials.list(vault_id: vault_id)
          expect(response["object"]).to eq("list")
          expect(response["data"]).to be_an(Array)
        end
      end
    end

    describe "#delete" do
      let(:cassette) { "agents vault credentials delete" }

      it "deletes the credential" do
        VCR.use_cassette(cassette) do
          expect(credentials.delete(vault_id: vault_id, id: credential_id)["deleted"]).to be(true)
        end
      end
    end
  end
end
