RSpec.describe OpenAI::Client do
  describe "#classifications", :vcr do
    let(:query) { "It is a raining day :(" }

    # context "with a file" do
    #   let(:cassette) { "#{engine} classifications file #{query}".downcase }
    #   let(:filename) { "puppy.jsonl" }
    #   let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
    #   let!(:file_id) do
    #     response = VCR.use_cassette("files upload classifications") do
    #       OpenAI::Client.new.files.upload(parameters: { file: file, purpose: "classifications" })
    #     end
    #     JSON.parse(response.body)["id"]
    #   end
    #   let(:response) do
    #     OpenAI::Client.new.classifications(
    #       parameters: {
    #         model: engine,
    #         query: query,
    #         file: file_id
    #       }
    #     )
    #   end

    #   context "with engine: davinci" do
    #     let(:engine) { "davinci" }

    #     it "classifications the query" do
    #       VCR.use_cassette(cassette) do
    #         expect(response.parsed_response["classifications"][0]).to include("puppy A is happy")
    #       end
    #     end
    #   end
    # end

    context "with examples" do
      let(:cassette) { "#{engine} classifications examples #{query}".downcase }
      let(:examples) { [
        ["A happy moment", "Positive"],
        ["I am sad.", "Negative"],
        ["I am feeling awesome", "Positive"]
      ] }

      let(:response) do
        OpenAI::Client.new.classifications(
          parameters: {
            model: engine,
            query: query,
            examples: examples
          }
        )
      end

      context "with engine: ada" do
        let(:engine) { "ada" }

        it "classifies the query" do
          VCR.use_cassette(cassette) do
            expect(response.parsed_response["selected_examples"][0]["text"]).to eq("I am feeling awesome")
          end
        end
      end
    end
  end
end
