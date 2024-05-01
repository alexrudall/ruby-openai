RSpec.describe OpenAI::Client do
  describe "#models" do
    describe "#list", :vcr do
      let(:response) { OpenAI::Client.new.models.list }
      let(:cassette) { "models list" }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response.dig("data", 0, "object")).to eq("model")
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "models retrieve" }
      let(:response) { OpenAI::Client.new.models.retrieve(id: "gpt-3.5-turbo-instruct") }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("model")
        end
      end
    end
  end
end
