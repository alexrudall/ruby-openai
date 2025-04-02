RSpec.describe OpenAI::Client do
  describe "#embeddings", :vcr do
    let(:input) { "The food was delicious and the waiter..." }
    let(:cassette) { "#{model} embeddings #{input}".downcase }
    let(:response) do
      OpenAI::Client.new.embeddings(
        parameters: {
          model: model,
          input: input
        }
      )
    end

    context "with model: text-embedding-ada-002" do
      let(:model) { "text-embedding-ada-002" }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response.dig("data", 0, "object")).to eq("embedding")
        end
      end
    end
  end
end
