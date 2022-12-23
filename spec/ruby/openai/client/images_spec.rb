RSpec.describe OpenAI::Client do
  describe "#images" do
    describe "#generate", :vcr do
      let(:response) do
        OpenAI::Client.new.images.generate(
          parameters: {
            prompt: prompt,
            size: size
          }
        )
      end
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

    describe "#edit", :vcr do
      let(:response) do
        OpenAI::Client.new.images.edit(
          parameters: {
            image: image,
            mask: mask,
            prompt: prompt,
            size: size
          }
        )
      end
      let(:cassette) { "images edit #{image_filename} #{prompt}" }
      let(:prompt) { "A solid red Ruby on a blue background" }
      let(:image) { File.join(RSPEC_ROOT, "fixtures/files", image_filename) }
      let(:image_filename) { "image.png" }
      let(:mask) { File.join(RSPEC_ROOT, "fixtures/files", mask_filename) }
      let(:mask_filename) { "mask.png" }
      let(:size) { "256x256" }

      it "succeeds" do
        VCR.use_cassette(cassette, preserve_exact_body_bytes: true) do
          r = JSON.parse(response.body)
          expect(r.dig("data", 0, "url")).to include("dalle")
        end
      end
    end
  end
end
