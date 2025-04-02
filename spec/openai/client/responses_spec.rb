RSpec.describe OpenAI::Client do
  describe "#responses" do
    describe "#create", :vcr do
      let(:model) { "gpt-4o" }
      let(:input) { "Hello!" }
      let(:stream) { false }
      let(:uri_base) { nil }
      let(:parameters) { { model: model, input: input, stream: stream } }
      let(:response) do
        OpenAI::Client.new({ uri_base: uri_base }).responses.create(
          parameters: parameters
        )
      end
      let(:content) { response.dig("output", 0, "content", 0, "text") }
      let(:cassette) { "responses create" }

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
          OpenAI::Client.new({ uri_base: uri_base }).responses.create(
            parameters: followup_parameters
          )
        end
        let(:followup_content) { followup_response.dig("output", 0, "content", 0, "text") }
        let(:cassette) { "responses create with followup" }

        it "remembers the conversation history" do
          VCR.use_cassette(cassette) do
            expect(content).to include("Szymon!")
            expect(followup_content).to include("Szymon")
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
          let(:cassette) { "responses create with tool call" }
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
        let(:cassette) { "responses stream" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            response
            output_text = chunks
                          .select { |chunk| chunk["type"] == "response.output_text.delta" }
                          .map { |chunk| chunk["delta"] }
                          .join
            expect(output_text).to include("?")
          end
        end

        context "with an object with a call method" do
          let(:cassette) { "responses stream without proc" }
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
              expect(output_text).to include("?")
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

    describe "#retrieve" do
      let(:model) { "gpt-4o" }
      let(:response_id) do
        VCR.use_cassette("responses retrieve setup") do
          OpenAI::Client.new.responses.create(
            parameters: {
              model: model,
              input: "Hello, this is a test response"
            }
          )["id"]
        end
      end
      let(:response) { OpenAI::Client.new.responses.retrieve(response_id: response_id) }
      let(:cassette) { "responses retrieve" }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("response")
          expect(response["id"]).to eq(response_id)
        end
      end
    end

    describe "#delete" do
      let(:model) { "gpt-4o" }
      let(:response_id) do
        VCR.use_cassette("responses delete setup") do
          OpenAI::Client.new.responses.create(
            parameters: {
              model: model,
              input: "Hello, this is a test response for deletion"
            }
          )["id"]
        end
      end
      let(:response) { OpenAI::Client.new.responses.delete(response_id: response_id) }
      let(:cassette) { "responses delete" }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["deleted"]).to eq(true)
          expect(response["id"]).to eq(response_id)
        end
      end
    end

    describe "#input_items" do
      let(:model) { "gpt-4o" }
      let(:response_id) do
        VCR.use_cassette("responses input_items setup") do
          OpenAI::Client.new.responses.create(
            parameters: {
              model: model,
              input: "Hello, this is a test response for listing input items"
            }
          )["id"]
        end
      end
      let(:response) { OpenAI::Client.new.responses.input_items(response_id: response_id) }
      let(:cassette) { "responses input_items" }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("list")
          expect(response["data"]).to be_an(Array)
        end
      end
    end
  end
end
