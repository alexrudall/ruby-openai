RSpec.describe OpenAI::Client do
  describe "#batches" do
    let(:batch_id) do
      VCR.use_cassette("#{cassette} setup") do
        OpenAI::Client.new.batches.create(
          parameters: {
            input_file_id: "file-7Z7mpvlObMQXQH2f2VbnhUqT",
            endpoint: "/v1/chat/completions",
            completion_window: "24h"
          }
        )["id"]
      end
    end

    describe "#list", :vcr do
      let(:response) { OpenAI::Client.new.batches.list }
      let(:cassette) { "batches list" }

      before { batch_id }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response.dig("data", 0, "object")).to eq("batch")
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "batches retrieve" }
      let(:response) { OpenAI::Client.new.batches.retrieve(id: batch_id) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("batch")
        end
      end
    end

    describe "#create" do
      let(:cassette) { "batches create" }
      let(:response) do
        OpenAI::Client.new.batches.create(parameters: {
                                            input_file_id: "file-7Z7mpvlObMQXQH2f2VbnhUqT",
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
      let(:cassette) { "batch cancel" }
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
