RSpec.describe OpenAI::Client do
  shared_examples "chat" do |model|
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

        context "with model: #{model}" do
          let(:model) { model }

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

          context "with an object with a call method" do
            let(:cassette) { "#{model} streamed chat without proc".downcase }
            let(:stream) do
              Class.new do
                attr_reader :chunks

                def initialize
                  @chunks = []
                end

                def call(chunk)
                  @chunks << chunk
                end
              end.new
            end

            it "succeeds" do
              VCR.use_cassette(cassette) do
                response
                expect(stream.chunks.dig(0, "choices", 0, "index")).to eq(0)
              end
            end
          end

          context "with an object without a call method" do
            let(:stream) { Object.new }

            it "raises an error" do
              VCR.use_cassette(cassette) do
                expect { response }.to raise_error(ArgumentError)
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

    include_examples "chat", "gpt-3.5-turbo"
    include_examples "chat", "gpt-3.5-turbo-0301"
    include_examples "chat", "gpt-4" if ENV["GPT4"]
  end

  context "with the default uri_base", :vcr do
    let(:custom_uri_base) { OpenAI::Configuration::DEFAULT_URI_BASE }

    before do
      OpenAI.configure do |config|
        config.uri_base = custom_uri_base
      end
    end

    include_examples "chat", "gpt-3.5-turbo"
    include_examples "chat", "gpt-3.5-turbo-0301"
    include_examples "chat", "gpt-4" if ENV["GPT4"]
  end
end
