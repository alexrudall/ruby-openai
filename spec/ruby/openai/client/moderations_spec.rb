RSpec.describe OpenAI::Client do
  describe "#moderations", :vcr do
    let(:input) { "I'm worried about that." }
    let(:cassette) { "moderations #{input}".downcase }
    let(:response) do
      OpenAI::Client.new.moderations(
        parameters: {
          input: input
        }
      )
    end

    it "succeeds" do
      VCR.use_cassette(cassette) do
        expect(response.dig("results", 0, "categories", "hate")).to eq(false)
      end
    end
  end
end
