RSpec.describe OpenAI::Client do
  describe "#fine tuning jobs", :vcr do
    let(:filename) { "sarcastic.jsonl" }
    let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
    let(:upload_id) do
      response = VCR.use_cassette("fine tune job files upload") do
        OpenAI::Client.new.files.upload(parameters: { file: file, purpose: "fine-tune" })
      end
      response["id"]
    end
    let(:retrieve_cassette) { "#{cassette} retrieve for fine tunings" }
    let(:file_id) do
      VCR.use_cassette(retrieve_cassette) do
        OpenAI::Client.new.files.retrieve(id: upload_id)
      end

      upload_id
    end
    let(:model) { "gpt-3.5-turbo-0613" }
    let(:create_response) do
      VCR.use_cassette("#{cassette} create") do
        OpenAI::Client.new.fine_tuning_jobs.create(
          parameters: {
            training_file: file_id,
            model: model
          }
        )
      end
    end
    let(:create_id) { create_response["id"] }

    describe "#list" do
      let(:cassette) { "fine tuning job list" }
      let(:response) { OpenAI::Client.new.fine_tuning_jobs.list }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response.dig("data", 0, "object")).to eq("fine_tuning.job")
        end
      end
    end

    describe "#create" do
      let(:cassette) { "fine_tuning_job" }

      it "succeeds" do
        expect(create_response["object"]).to eq("fine_tuning.job")
      end
    end

    describe "#retrieve" do
      let(:cassette) { "fine tuning job retrieve" }
      let(:response) { OpenAI::Client.new.fine_tuning_jobs.retrieve(id: create_response["id"]) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("fine_tuning.job")
        end
      end
    end

    describe "#cancel" do
      let(:cassette) { "fine tuning job cancel" }
      let(:response) { OpenAI::Client.new.fine_tuning_jobs.cancel(id: 123) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response.dig("error", "code")).to eq("fine_tune_not_found")
        end
      end
    end

    describe "#list_events" do
      let(:cassette) { "fine tuning job event list" }
      let(:response) { OpenAI::Client.new.fine_tuning_jobs.list_events(id: create_response["id"]) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response.dig("data", 0, "object")).to eq("fine_tuning.job.event")
        end
      end
    end
  end
end
