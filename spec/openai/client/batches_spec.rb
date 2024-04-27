RSpec.describe OpenAI::Client do
  describe "#batches" do
    let(:filename) { "batch.jsonl" }
    let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
    let(:upload_purpose) { "batch" }
    let(:input_file) do
      VCR.use_cassette(input_cassette) do
        OpenAI::Client.new.files.upload(parameters: { file: file, purpose: upload_purpose })
      end
    end
    let(:input_file_id) { input_file["id"] }
    let(:batch_id) do
      VCR.use_cassette("#{cassette} setup") do
        OpenAI::Client.new.batches.create(
          parameters: {
            input_file_id: input_file_id,
            endpoint: "/v1/chat/completions",
            completion_window: "24h"
          }
        )["id"]
      end
    end

    describe "#list", :vcr do
      let(:input_cassette) { "batches list input" }
      let(:cassette) { "batches list" }
      let(:response) { OpenAI::Client.new.batches.list }

      before { batch_id }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response.dig("data", 0, "object")).to eq("batch")
        end
      end
    end

    describe "#retrieve" do
      let(:input_cassette) { "batches retrieve input" }
      let(:cassette) { "batches retrieve" }
      let(:response) { OpenAI::Client.new.batches.retrieve(id: batch_id) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("batch")
        end
      end
    end

    describe "#create" do
      let(:input_cassette) { "batches create input" }
      let(:cassette) { "batches create" }
      let(:response) do
        OpenAI::Client.new.batches.create(parameters: {
                                            input_file_id: input_file_id,
                                            endpoint: "/v1/chat/completions",
                                            completion_window: "24h"
                                          })
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq "batch"
        end
      end
    end

    describe "#cancel" do
      let(:input_cassette) { "batches cancel input" }
      let(:cassette) { "batches cancel" }
      let(:response) do
        OpenAI::Client.new.batches.cancel(id: batch_id)
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq "batch"
        end
      end
    end
  end
end
