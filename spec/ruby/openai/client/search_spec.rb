RSpec.describe OpenAI::Client do
  describe "#search", :vcr do
    let(:cassette) { "#{engine} search #{query}".downcase }

    context "with a file" do
      let(:filename) { "puppy.jsonl" }
      let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
      let!(:file_id) do
        response = VCR.use_cassette("files upload search") do
          OpenAI::Client.new.files.upload(parameters: { file: file, purpose: "search" })
        end
        JSON.parse(response.body)["id"]
      end

      context "with engine: text-davinci-001" do
        let(:query) { "happy" }
        let(:engine) { "text-davinci-001" }
        let(:response) do
          OpenAI::Client.new.search(
            engine: engine,
            parameters: {
              file: file_id,
              query: query
            }
          )
        end

        it "finds the best match" do
          VCR.use_cassette(cassette) do
            expect(response.parsed_response["data"][0]["text"]).to eq("puppy A is happy")
          end
        end
      end
    end

    context "with documents" do
      let(:documents) { %w[washington hospital school] }
      let(:query) { "the president" }
      let(:response) do
        OpenAI::Client.new.search(
          engine: engine,
          parameters: {
            documents: documents,
            query: query
          }
        )
      end
      let(:best_match) { JSON.parse(response.body)["data"].max_by { |d| d["score"] }["document"] }

      context "with engine: text-ada-001" do
        let(:engine) { "text-ada-001" }

        it "finds the best match" do
          VCR.use_cassette(cassette) do
            expect(documents[best_match]).to eq("washington")
          end
        end
      end

      context "with engine: text-babbage-001" do
        let(:engine) { "text-babbage-001" }

        it "finds the best match" do
          VCR.use_cassette(cassette) do
            expect(documents[best_match]).to eq("washington")
          end
        end
      end

      context "with engine: text-curie-001" do
        let(:engine) { "text-curie-001" }

        it "finds the best match" do
          VCR.use_cassette(cassette) do
            expect(documents[best_match]).to eq("washington")
          end
        end
      end

      context "with engine: text-davinci-001" do
        let(:engine) { "text-davinci-001" }

        it "finds the best match" do
          VCR.use_cassette(cassette) do
            expect(documents[best_match]).to eq("washington")
          end
        end
      end
    end
  end
end
