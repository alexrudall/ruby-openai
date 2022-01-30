RSpec.describe OpenAI::Client do
  describe "#engines" do
    describe "#list", :vcr do
      let(:response) { OpenAI::Client.new.engines.list }
      let(:cassette) { "engines list" }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          r = JSON.parse(response.body)
          expect(r["data"][0]["object"]).to eq("engine")
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "engines retrieve" }
      let(:response) { OpenAI::Client.new.engines.retrieve(id: "text-ada-001") }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          r = JSON.parse(response.body)
          expect(r["object"]).to eq("engine")
        end
      end
    end
  end
end
