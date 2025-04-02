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

  describe "#delete" do
    let(:cassette) { "models delete" }
    let(:model_id) { "ft:123" }

    it "sends request to the correct endpoint" do
      VCR.use_cassette(cassette) do
        OpenAI::Client.new.models.delete(id: model_id)
      rescue Faraday::ResourceNotFound => e
        error_expected = "The model '#{model_id}' does not exist"
        expect(e.response.dig(:body, "error", "message")).to eq(error_expected)

        # Just verify the exception is raised as expected
        expect(e).to be_a(Faraday::ResourceNotFound)
      end
    end
  end
end
