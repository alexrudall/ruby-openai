RSpec.describe OpenAI::Client do
  describe "#fine tuning job", :vcr do
    let(:filename) { "sarcastic.jsonl" }
    let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
    let!(:upload_id) do
      response = VCR.use_cassette("finetunes files upload") do
        OpenAI::Client.new.files.upload(parameters: { file: file, purpose: "fine-tune" })
      end
      response["id"]
    end
    let(:retrieve_cassette) { "#{cassette} retrieve for fine tunings" }
    let(:file_id) do
      retrieved = VCR.use_cassette(retrieve_cassette) do
        OpenAI::Client.new.files.retrieve(id: upload_id)
      end
      tries = 0
      until retrieved["status"] == "processed"
        raise "File not processed after 10 tries" if tries > 10

        sleep(1)
        retrieved = VCR.use_cassette(retrieve_cassette, record: :all) do
          OpenAI::Client.new.files.retrieve(id: upload_id)
        end
        tries += 1
      end

      upload_id
    end
    let(:model) { "gpt-3.5-turbo-0613" }
    let!(:create_response) do
      VCR.use_cassette("#{cassette} create") do
        OpenAI::Client.new.fine_tuning_job.create(
          parameters: {
            training_file: file_id,
            model: model
          }
        )
      end
    end
    let(:create_id) { create_response["id"] }

    describe "#create" do
      let(:cassette) { "fine_tuning_job" }

      it "succeeds" do
        expect(create_response["object"]).to eq("fine_tuning.job")
      end
    end

    describe "#list" do
      let(:cassette) { "fine tuning job list" }
      let(:response) { OpenAI::Client.new.fine_tuning_job.list(id: create_response["id"]) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response.dig("data", 0, "object")).to eq("fine_tuning.job.event")
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "fine tuning job retrieve" }
      let(:response) { OpenAI::Client.new.fine_tuning_job.retrieve(id: create_response["id"]) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("fine_tuning.job")
        end
      end
    end

    describe "#cancel" do
      let(:cassette) { "fine tuning job cancel" }
      let(:response) { OpenAI::Client.new.fine_tuning_job.cancel(id: create_response["id"]) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["id"]).to eq(create_id)
          expect(response["status"]).to eq("cancelled")
        end
      end
    end
  end
end
