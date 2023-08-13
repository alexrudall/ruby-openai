require "tempfile"

RSpec.describe OpenAI::Client do
  describe "#transcribe" do
    context "with audio", :vcr do
      let(:filename) { "audio_sample.mp3" }
      let(:audio) { File.join(RSPEC_ROOT, "fixtures/files", filename) }

      let(:response) do
        OpenAI::Client.new.transcribe(
          parameters: {
            model: model,
            file: file
          }
        )
      end
      let(:content) { response["text"] }
      let(:cassette) { "#{model} transcribe #{file.class}".downcase }

      context "with model: whisper-1" do
        let(:model) { "whisper-1" }

        context "with file" do
          let(:file) { File.open(audio, "rb") }

          it "succeeds" do
            VCR.use_cassette(cassette) do
              expect(content.empty?).to eq(false)
            end
          end
        end

        context "with tempfile" do
          let(:file) do
            temp = Tempfile.new([filename, ".mp3"])
            temp.write(File.read(audio))
            temp.rewind

            # File.rename(temp.path, "fixtures/files")

            temp
          end

          it "succeeds" do
            VCR.use_cassette(cassette) do
              expect(content.empty?).to eq(false)
            end
          end
        end
      end
    end
  end

  describe "#translate" do
    context "with audio", :vcr do
      let(:filename) { "audio_sample.mp3" }
      let(:audio) { File.join(RSPEC_ROOT, "fixtures/files", filename) }

      let(:response) do
        OpenAI::Client.new.translate(
          parameters: {
            model: model,
            file: File.open(audio, "rb")
          }
        )
      end
      let(:content) { response["text"] }
      let(:cassette) { "#{model} translate".downcase }

      context "with model: whisper-1" do
        let(:model) { "whisper-1" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(content.empty?).to eq(false)
          end
        end
      end
    end
  end
end
