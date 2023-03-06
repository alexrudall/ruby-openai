RSpec.describe OpenAI::Client do
  describe "#models", :vcr do
    let(:response) { OpenAI::Client.new.models }
    let(:cassette) { "models" }

    it "succeeds" do
      VCR.use_cassette(cassette) do
        r = JSON.parse(response.body)
        expect(r["data"][0]["object"]).to eq("model")
      end
    end
  end

  describe "#model" do
    let(:cassette) { "model" }
    let(:response) { OpenAI::Client.new.model(id: "text-ada-001") }

    it "succeeds" do
      VCR.use_cassette(cassette) do
        r = JSON.parse(response.body)
        expect(r["object"]).to eq("model")
      end
    end
  end
end
