RSpec.describe OpenAI::Client do
  describe "#audio" do
    describe "#transcribe" do
      context "with audio", :vcr do
        let(:filename) { "audio_sample.mp3" }
        let(:audio) { File.join(RSPEC_ROOT, "fixtures/files", filename) }

        let(:response) do
          OpenAI::Client.new.audio.transcribe(
            parameters: {
              model: model,
              file: File.open(audio, "rb")
            }
          )
        end
        let(:content) { response["text"] }
        let(:cassette) { "audio #{model} transcribe".downcase }

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

    describe "#translate" do
      context "with audio", :vcr do
        let(:filename) { "audio_sample.mp3" }
        let(:audio) { File.join(RSPEC_ROOT, "fixtures/files", filename) }

        let(:response) do
          OpenAI::Client.new.audio.translate(
            parameters: {
              model: model,
              file: File.open(audio, "rb")
            }
          )
        end
        let(:content) { response["text"] }
        let(:cassette) { "audio #{model} translate".downcase }

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
end
