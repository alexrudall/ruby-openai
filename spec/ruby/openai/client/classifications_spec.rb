RSpec.describe OpenAI::Client do
  describe "#classifications", :vcr do
    context "with a file" do
      let(:query) { "movie is very good" }
      let(:cassette) { "#{model} classifications file #{query}".downcase }
      let(:filename) { "train.jsonl" }
      let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
      let!(:file_id) do
        response = VCR.use_cassette("files upload classifications") do
          OpenAI::Client.new.files.upload(parameters: { file: file, purpose: "classifications" })
        end
        JSON.parse(response.body)["id"]
      end
      let(:response) do
        OpenAI::Client.new.classifications(
          parameters: {
            model: model,
            query: query,
            file: file_id
          }
        )
      end

      context "with model: text-curie-001" do
        let(:model) { "text-curie-001" }

        it "classifies the query" do
          VCR.use_cassette(cassette) do
            expect(response["label"]).to eq("Positive")
          end
        end
      end
    end

    context "with examples" do
      let(:query) { "It is a raining day :(" }
      let(:cassette) { "#{model} classifications examples #{query}".downcase }
      let(:examples) do
        [
          ["A happy moment", "Positive"],
          ["I am sad.", "Negative"],
          ["I am feeling awesome", "Positive"]
        ]
      end

      let(:response) do
        OpenAI::Client.new.classifications(
          parameters: {
            model: model,
            query: query,
            examples: examples
          }
        )
      end

      context "with model: text-ada-001" do
        let(:model) { "text-ada-001" }

        it "classifies the query" do
          VCR.use_cassette(cassette) do
            expect(response["label"]).to eq("Negative")
          end
        end
      end
    end
  end
end
