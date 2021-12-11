RSpec.describe OpenAI::Client do
  describe "#embeddings", :vcr do
    let(:input) { "The food was delicious and the waiter..." }
    let(:cassette) { "#{engine} embeddings #{input}".downcase }
    let(:response) do
      OpenAI::Client.new.embeddings(
        engine: engine,
        parameters: {
          input: input
        }
      )
    end

    context "with engine: babbage-similarity" do
      let(:engine) { "babbage-similarity" }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["data"][0]["object"]).to eq("embedding")
        end
      end
    end
  end
end
