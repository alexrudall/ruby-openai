RSpec.describe OpenAI::Client do
  describe "#answers", :vcr do
    let(:question) { "which puppy is happy?" }
    let(:examples) { [["What is human life expectancy in the United States?", "78 years."]] }
    let(:examples_context) { "In 2017, U.S. life expectancy was 78.6 years." }

    context "with a file" do
      let(:cassette) { "#{engine} answers file #{question}".downcase }
      let(:filename) { "puppy.jsonl" }
      let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
      let!(:file_id) do
        response = VCR.use_cassette("files upload answers") do
          OpenAI::Client.new.files.upload(parameters: { file: file, purpose: "answers" })
        end
        JSON.parse(response.body)["id"]
      end
      let(:response) do
        OpenAI::Client.new.answers(
          parameters: {
            model: engine,
            question: question,
            examples: examples,
            examples_context: examples_context,
            file: file_id
          }
        )
      end

      context "with engine: davinci" do
        let(:engine) { "davinci" }

        it "answers the question" do
          VCR.use_cassette(cassette) do
            expect(response.parsed_response["answers"][0]).to include("puppy A is happy")
          end
        end
      end
    end

    context "with documents" do
      let(:cassette) { "#{engine} answers documents #{question}".downcase }
      let(:documents) { ["Puppy A is happy", "Puppy B is sad."] }

      let(:response) do
        OpenAI::Client.new.answers(
          parameters: {
            model: engine,
            question: question,
            examples: examples,
            examples_context: examples_context,
            documents: documents,
          }
        )
      end

      context "with engine: ada" do
        let(:engine) { "ada" }

        it "answers the question" do
          VCR.use_cassette(cassette) do
            expect(response.parsed_response["answers"][0]).to include("Puppy A.")
          end
        end
      end
    end
  end
end
