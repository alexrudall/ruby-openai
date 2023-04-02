RSpec.describe OpenAI::Client do
  describe "#chat" do
    context "with messages", :vcr do
      let(:messages) { [{ role: "user", content: "Hello!" }] }
      let(:stream) { false }
      let(:on_data) { nil }
      let(:response) do
        OpenAI::Client.new.chat(
          parameters: {
            model: model,
            messages: messages,
            stream: stream,
            on_data: on_data
          }
        )
      end
      let(:content) { JSON.parse(response.body).dig("choices", 0, "message", "content") }
      let(:cassette) { "#{model} #{'streamed' if stream} chat".downcase }

      context "with model: gpt-3.5-turbo" do
        let(:model) { "gpt-3.5-turbo" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(content.split.empty?).to eq(false)
          end
        end

        describe "streaming" do
          let(:stream) { true }
          let(:chunks) { [] }
          let(:on_data) do
            proc do |chunk, _bytesize|
              chunks << chunk
            end
          end

          it "succeeds" do
            VCR.use_cassette(cassette) do
              response
              expect(chunks.empty?).to eq(false)
            end
          end
        end
      end

      context "with model: gpt-3.5-turbo-0301" do
        let(:model) { "gpt-3.5-turbo-0301" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(content.split.empty?).to eq(false)
          end
        end
      end
    end
  end
end
