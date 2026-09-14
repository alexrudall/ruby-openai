RSpec.describe OpenAI::Client do
  describe "#agents.sessions.artifacts" do
    let(:client) { OpenAI::Client.new }
    let(:base) { "https://api.openai.com/v1/agents/sessions/sess_x/artifacts" }
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
      let(:cassette) { "agents session artifacts list" }

      it "lists artifacts" do
        VCR.use_cassette(cassette) do
          response = client.agents.sessions.artifacts.list(session_id: session_id)
          expect(response["object"]).to eq("list")
          expect(response["data"]).to eq([])
        end
      end
    end

    describe "#retrieve" do
      it "requests the artifact" do
        stub = stub_request(:get, "#{base}/art_1").to_return(status: 200,
                                                             body: { id: "art_1" }.to_json)
        response = client.agents.sessions.artifacts.retrieve(session_id: "sess_x", id: "art_1")
        expect(stub).to have_been_requested
        expect(response["id"]).to eq("art_1")
      end
    end

    describe "#delete" do
      it "deletes the artifact" do
        stub = stub_request(:delete, "#{base}/art_1")
               .to_return(status: 200, body: { id: "art_1", deleted: true }.to_json)
        response = client.agents.sessions.artifacts.delete(session_id: "sess_x", id: "art_1")
        expect(stub).to have_been_requested
        expect(response["deleted"]).to be(true)
      end
    end

    describe "#content" do
      it "returns the raw bytes" do
        stub = stub_request(:get, "#{base}/art_1/content")
               .with(headers: { "Accept" => "application/octet-stream" })
               .to_return(status: 200, body: "raw bytes",
                          headers: { "Content-Type" => "application/octet-stream" })
        response = client.agents.sessions.artifacts.content(session_id: "sess_x", id: "art_1")
        expect(stub).to have_been_requested
        expect(response).to eq("raw bytes")
      end
    end
  end
end
