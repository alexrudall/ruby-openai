RSpec.describe OpenAI::Client do
  describe "#assistant_files", :vcr do
    let(:filename) { "algebra_formulas.pdf" }
    let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
    let(:assistant_id) { "asst_KfrvKUIYCRCzmwuGe9uuHBHJ" }
    let(:assistant_file_id) { "file-wB6RM6wHdA49HfS2DJ9fEyrH" }
    let(:assistant) do
      VCR.use_cassette("assistants retrieve") do
        OpenAI::Client.new.assistants.retrieve(id: assistant_id)
      end
    end

    # TODO: Remove once assistants API is out of beta
    before do
      OpenAI.configuration.extra_headers = { "OpenAI-Beta" => "assistants=v1" }
    end

    describe "#upload" do
      let(:cassette) { "assistant files upload" }
      let(:response) do
        OpenAI::Client.new.assistant_files(assistant_id: assistant_id).upload(
          parameters: { file: file }
        )
      end

      context "with a valid file format" do
        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(response["filename"]).to eq(filename)
          end
        end
      end

      context "with an invalid file" do
        let(:filename) { File.join("errors", "missing_quote.jsonl") }

        it { expect { response }.to raise_error(OpenAI::AssistantFiles::InvalidFileFormat) }
      end
    end

    describe "#list" do
      let(:cassette) { "assistant files list" }
      let(:response) { OpenAI::Client.new.assistant_files(assistant_id: assistant_id).list }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response.dig("data", 0, "object")).to eq("assistant.file")
          expect(response.dig("data", 0, "object")).to eq("assistant.file")
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "assistant files retrieve" }
      let(:response) do
        OpenAI::Client.new.assistant_files(assistant_id: assistant_id).retrieve(
          id: assistant_file_id
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("assistant.file")
          expect(response["assistant_id"]).to eq(assistant_id)
        end
      end
    end

    describe "#delete" do
      let(:cassette) { "assistant files delete" }
      let(:response) do
        OpenAI::Client.new.assistant_files(assistant_id: assistant_id).delete(id: assistant_file_id)
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["id"]).to eq(assistant_file_id)
          expect(response["deleted"]).to eq(true)
        end
      end
    end
  end
end
