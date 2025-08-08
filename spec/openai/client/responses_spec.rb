RSpec.describe OpenAI::Client do
  describe "#responses" do
    context "with basic text generation", :vcr do
      let(:input) { "What is the capital of France?" }
      let(:model) { "gpt-4" }
      let(:response) do
        OpenAI::Client.new.responses(
          parameters: parameters
        )
      end
      let(:parameters) { { model: model, input: input } }
      let(:cassette) { "responses #{model} basic text generation".downcase }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response).to include("output")
          expect(response["output"]).to be_an(Array)
          expect(response["output"].length).to be > 0
          
          # Find the message output in the output array
          message_output = response["output"].find { |output| output["type"] == "message" }
          expect(message_output).not_to be_nil
          expect(message_output.dig("content", 0, "text")).not_to be_empty
        end
      end
    end

    context "with file search capabilities", :vcr do
      let(:input) { "Search for information about Ruby programming in the uploaded documents." }
      let(:model) { "gpt-4" }
      let(:vector_store_id) { "vs_nonexistent123" } # Non-existent vector store ID for error testing
      let(:response) do
        OpenAI::Client.new.responses(
          parameters: parameters
        )
      end
      let(:parameters) do
        {
          model: model,
          input: input,
          tools: [
            {
              type: "file_search",
              vector_store_ids: [vector_store_id]
            }
          ]
        }
      end
      let(:cassette) { "responses #{model} file search error".downcase }

      it "raises error with invalid vector store ID" do
        VCR.use_cassette(cassette) do
          expect { response }.to raise_error(Faraday::Error)
        end
      end
    end

    context "error handling", :vcr do
      context "with missing required parameters" do
        let(:response) do
          OpenAI::Client.new.responses(
            parameters: { model: "gpt-4" } # Missing input parameter
          )
        end
        let(:cassette) { "responses missing input parameter".downcase }

        it "raises an error for missing input" do
          VCR.use_cassette(cassette) do
            expect { response }.to raise_error(Faraday::Error)
          end
        end
      end

      context "with invalid model" do
        let(:response) do
          OpenAI::Client.new.responses(
            parameters: { 
              model: "invalid-model-name",
              input: "Test input"
            }
          )
        end
        let(:cassette) { "responses invalid model".downcase }

        it "raises an error for invalid model" do
          VCR.use_cassette(cassette) do
            expect { response }.to raise_error(Faraday::Error)
          end
        end
      end
    end

    context "parameter validation" do
      context "with valid required parameters" do
        let(:input) { "Test input for parameter validation" }
        let(:model) { "gpt-4" }
        let(:response) do
          OpenAI::Client.new.responses(
            parameters: { model: model, input: input }
          )
        end
        let(:cassette) { "responses parameter validation".downcase }

        it "accepts required parameters", :vcr do
          VCR.use_cassette(cassette) do
            expect(response).to include("output")
            expect(response["output"]).to be_an(Array)
          end
        end
      end

      context "with additional optional parameters" do
        let(:input) { "Test with optional parameters" }
        let(:model) { "gpt-4" }
        let(:response) do
          OpenAI::Client.new.responses(
            parameters: {
              model: model,
              input: input,
              max_output_tokens: 100,
              temperature: 0.7
            }
          )
        end
        let(:cassette) { "responses optional parameters".downcase }

        it "accepts optional parameters", :vcr do
          VCR.use_cassette(cassette) do
            expect(response).to include("output")
            expect(response["output"]).to be_an(Array)
            
            message_output = response["output"].find { |output| output["type"] == "message" }
            expect(message_output).not_to be_nil
            expect(message_output.dig("content", 0, "text")).not_to be_empty
          end
        end
      end
    end
  end
end