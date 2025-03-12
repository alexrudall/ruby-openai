RSpec.describe OpenAI::Client do
  describe "#responses" do
    context "with messages", :vcr do
      let(:model) { "gpt-4o" }
      let(:input) { "Hello!" }
      let(:stream) { false }
      let(:uri_base) { nil }
      let(:response) do
        OpenAI::Client.new({ uri_base: uri_base }).responses(
          parameters: parameters
        )
      end
      let(:parameters) { { model: model, input: input, stream: stream } }
      let(:content) { response.dig("output", 0, "content", 0, "text") }
      let(:provider) { nil }
      let(:cassette) do
        "#{provider}#{model} #{stream ? 'streamed' : ''} ResponsesAPI responses".downcase
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(content.split.empty?).to eq(false)
        end
      end

      context "with followup message" do
        let(:input) { "Hello! My name is Szymon." }
        let(:input_followup) { "Remind me, what is my name?" }
        let(:previous_response_id) { response["id"] }
        let(:followup_parameters) do
          { model: model, input: input_followup, stream: stream,
            previous_response_id: previous_response_id }
        end
        let(:followup_response) do
          OpenAI::Client.new({ uri_base: uri_base }).responses(
            parameters: followup_parameters
          )
        end
        let(:followup_content) { followup_response.dig("output", 0, "content", 0, "text") }
        let(:cassette) do
          message_suffix = "with followup message ResponsesAPI responses"
          "#{if provider
               "#{provider}_"
             end}#{model} #{stream ? 'streamed' : ''} #{message_suffix}".downcase
        end

        it "remembers the conversation history" do
          VCR.use_cassette(cassette) do
            expect(content).to eq("Hello, Szymon! How can I assist you today?")
            expect(followup_content).to eq("Your name is Szymon.")
          end
        end
      end

      context "with a tool call" do
        let(:parameters) do
          {
            model: model,
            input: input,
            stream: stream,
            tools: tools
          }
        end
        let(:tools) do
          [
            {
              "type" => "function",
              "name" => "get_current_weather",
              "description" => "Get the current weather in a given location",
              "parameters" =>
                {
                  "type" => "object",
                  "properties" => {
                    "location" => {
                      "type" => "string",
                      "description" => "The geographic location to get the weather for"
                    }
                  },
                  "required" => ["location"]
                }
            }
          ]
        end

        context "with a valid message" do
          let(:cassette) { "#{model} valid tool call ResponsesAPI responses".downcase }
          let(:input) { "What is the weather like in the Peak District?" }

          it "succeeds" do
            VCR.use_cassette(cassette) do
              expect(response.dig("output", 0, "type")).to eq("function_call")
              expect(response.dig("output", 0, "name")).to eq("get_current_weather")
              expect(response.dig("output", 0, "arguments")).to include("Peak District")
            end
          end
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
            output_text = chunks
                          .select { |chunk| chunk["type"] == "response.output_text.delta" }
                          .map { |chunk| chunk["delta"] }
                          .join

            expect(output_text).to eq("Hi there! How can I assist you today?")
          end
        end

        context "with an object with a call method" do
          let(:cassette) { "#{model} streamed ResponsesAPI responses without proc".downcase }
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
              output_text = stream.chunks
                                  .select { |chunk| chunk["type"] == "response.output_text.delta" }
                                  .map { |chunk| chunk["delta"] }
                                  .join

              expect(output_text).to eq("Hi there! How can I assist you today?")
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
