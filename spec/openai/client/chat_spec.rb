RSpec.describe OpenAI::Client do
  describe "#chat" do
    context "with messages", :vcr do
      let(:messages) { [{ role: "user", content: "Hello!" }] }
      let(:stream) { false }
      let(:deployment_id) { nil }
      let(:response) do
        OpenAI::Client.new.chat(
          deployment_id: deployment_id,
          parameters: {
            model: model,
            messages: messages,
            stream: stream
          }
        )
      end
      let(:content) { response.dig("choices", 0, "message", "content") }
      let(:cassette) { "#{model} #{'streamed' if stream} chat".downcase }

      context "with model: gpt-3.5-turbo" do
        let(:model) { "gpt-3.5-turbo" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(content.split.empty?).to eq(false)
          end
        end

        describe "streaming" do
          let(:chunks) { [] }
          let(:stream) do
            proc do |chunk, _bytesize|
              chunks << chunk
            end
          end

          it "succeeds" do
            VCR.use_cassette(cassette) do
              response
              expect(chunks.dig(0, "choices", 0, "index")).to eq(0)
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

      context "with Azure" do
        let(:model) { "gpt-3.5-turbo-0301" }
        let(:deployment_id) { ENV.fetch("AZURE_DEPLOYMENT_ID") }

        before do
          OpenAI.configure do |config|
            config.api_type = :azure
            config.api_version = "2023-03-15-preview"
            config.uri_base = ENV.fetch("AZURE_URI_BASE")
            config.access_token = ENV.fetch("AZURE_ACCESS_TOKEN")
          end
        end

        after do
          OpenAI.configure do |config|
            config.api_type = :azure
            config.api_version = "2023-03-15-preview"
            config.uri_base = nil
            config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN", nil)
          end
        end

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(content.split.empty?).to eq(false)
          end
        end
      end
    end
  end
end
