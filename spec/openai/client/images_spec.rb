RSpec.describe OpenAI::Client do
  describe "#generate_images", :vcr do
    let(:response) do
      OpenAI::Client.new.generate_images(
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

  describe "#edit_image", :vcr do
    let(:response) do
      OpenAI::Client.new.edit_image(
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

  describe "#image_variations", :vcr do
    let(:response) do
      OpenAI::Client.new.image_variations(
        parameters: {
          image: image,
          n: 2,
          size: size
        }
      )
    end
    let(:cassette) { "images variations #{image_filename}" }
    let(:image) { File.join(RSPEC_ROOT, "fixtures/files", image_filename) }
    let(:image_filename) { "image.png" }
    let(:size) { "256x256" }

    it "succeeds" do
      VCR.use_cassette(cassette, preserve_exact_body_bytes: true) do
        r = JSON.parse(response.body)
        expect(r.dig("data", 0, "url")).to include("dalle")
      end
    end
  end
end
