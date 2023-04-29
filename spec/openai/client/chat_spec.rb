RSpec.describe OpenAI::Client do
  shared_examples "completions" do |model|
    describe "#chat" do
      context "with messages", :vcr do
        let(:messages) { [{ role: "user", content: "Hello!" }] }
        let(:stream) { false }
        let(:response) do
          OpenAI::Client.new.chat(
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

        context "with model: gpt-4" do
          let(:model) { "gpt-4" }
          let(:messages) do
            [{ role: "user",
               content: "What is the maximum weight allowed in the closed drawer or in " \
                        "combination  of inside and on top of the open drawer?" }]
          end

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
      end
    end
  end

  context "with the Helicone uri_base", :vcr do
    let(:custom_uri_base) { "https://oai.hconeai.com/" }

    before do
      OpenAI.configure do |config|
        config.uri_base = custom_uri_base
      end
    end

    include_examples "completions", "gpt-3.5-turbo"
    include_examples "completions", "gpt-3.5-turbo-0301"
    include_examples "completions", "gpt-4"
  end

  context "with the default uri_base", :vcr do
    let(:custom_uri_base) { OpenAI::Configuration::DEFAULT_URI_BASE }

    before do
      OpenAI.configure do |config|
        config.uri_base = custom_uri_base
      end
    end

    include_examples "completions", "gpt-3.5-turbo"
    include_examples "completions", "gpt-3.5-turbo-0301"
    include_examples "completions", "gpt-4"
  end
end
