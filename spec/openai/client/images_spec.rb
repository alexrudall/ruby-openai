RSpec.describe OpenAI::Client do
  describe "#images" do
    describe "#dall-e-2" do
      describe "#generate", :vcr do
        let(:response) do
          OpenAI::Client.new.images.generate(
            parameters: {
              prompt: prompt,
              size: size,
              model: model
            }
          )
        end
        let(:cassette) { "images generate #{prompt}" }
        let(:prompt) { "A baby sea otter cooking pasta wearing a hat of some sort" }
        let(:size) { "256x256" }
        let(:model) { "dall-e-2" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(response.dig("data", 0, "url")).to include("dalle")
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
              size: size,
              model: model
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
        let(:model) { "dall-e-2" }

        it "succeeds" do
          VCR.use_cassette(cassette, preserve_exact_body_bytes: true) do
            expect(response.dig("data", 0, "url")).to include("dalle")
          end
        end
      end

      describe "#variations", :vcr do
        let(:response) do
          OpenAI::Client.new.images.variations(
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
            expect(response.dig("data", 0, "url")).to include("dalle")
          end
        end
      end
    end

    describe "#dall-e-3" do
      describe "#generate" do
        describe "#standard", :vcr do
          let(:response) do
            OpenAI::Client.new.images.generate(
              parameters: {
                prompt: prompt,
                size: size,
                model: model
              }
            )
          end
          let(:cassette) { "images generate #{prompt}" }
          let(:prompt) { "A lion cooking pasta wearing a hat of some sort" }
          let(:size) { "1024x1792" } # using a size only available in dall-e-3
          let(:model) { "dall-e-3" }

          it "succeeds" do
            VCR.use_cassette(cassette) do
              expect(response.dig("data", 0, "url")).to include("dalle")
            end
          end
        end

        describe "#hd", :vcr do
          let(:response) do
            OpenAI::Client.new.images.generate(
              parameters: {
                prompt: prompt,
                size: size,
                model: model,
                quality: quality
              }
            )
          end
          let(:cassette) { "images generate #{prompt}" }
          let(:prompt) { "A lion cooking pasta wearing a hat of some sort" }
          let(:size) { "1024x1792" }
          let(:model) { "dall-e-3" }
          let(:quality) { "hd" }

          it "succeeds" do
            VCR.use_cassette(cassette) do
              expect(response.dig("data", 0, "url")).to include("dalle")
            end
          end
        end
      end
    end
  end
end
