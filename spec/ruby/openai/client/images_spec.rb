RSpec.describe OpenAI::Client do
  describe "#images" do
    describe "#generate", :vcr do
      let(:response) {
        OpenAI::Client.new.images.generate(
          parameters: {
            prompt: prompt,
            size: size,
          }
        )
      }
      let(:cassette) { "images generate #{prompt}" }
      let(:prompt) { "A baby sea otter cooking pasta wearing a hat of some sort" }
      let(:size) { "256x256" }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          r = JSON.parse(response.body)
          expect(r.dig("data", 0, "url")).to include("dalle")
        end
      end
    end
  end
end
