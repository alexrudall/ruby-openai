RSpec.describe OpenAI::Client do
  describe "#assistant_files", :vcr do
    let(:filename) { "algebra_formulas.pdf" }
    let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
    let(:existing_assistant_file) do
      OpenAI::Client.new.assistant_files(assistant_id: assistant_id).upload(
        parameters: { file: file }
      )
    end
    let(:assistant_file_id) { existing_assistant_file["id"] }
    let(:assistant) do
      OpenAI::Client.new.assistants.create(parameters: { model: "gpt-4",
                                                         name: "OpenAI-Ruby test assistant" })
    end
    let(:assistant_id) { assistant["id"] }

    # TODO: Remove once assistants API is out of beta
    before(:all) do
      OpenAI.configuration.extra_headers = { "OpenAI-Beta" => "assistants=v1" }
      VCR.insert_cassette("assistants create")
      VCR.insert_cassette("assistants files upload")
    end

    after(:each) { VCR.eject_cassette }

    describe "#upload" do
      let(:cassette) { "assistant files upload" }
      let(:response) do
        existing_assistant_file
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["filename"]).to eq(filename)
        end
      end
    end

    describe "#list" do
      let(:cassette) { "assistant files list" }
      let(:response) do
        existing_assistant_file
        OpenAI::Client.new.assistant_files(assistant_id: assistant_id).list
      end

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
        existing_assistant_file
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

      context "when  the assistant file does not exist" do
        it "raises an error" do
          VCR.use_cassette(cassette) do
            expect(response["object"]).to eq("assistant.file")
            expect(response["assistant_id"]).to eq(assistant_id)
          end
        end
      end
    end

    describe "#delete" do
      let(:cassette) { "assistant files delete" }
      let(:response) do
        existing_assistant_file
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
