RSpec.describe OpenAI::Client do
  describe "#vector_store_file_batches" do
    let(:vector_store_id) do
      VCR.use_cassette("#{cassette} vector_store setup") do
        OpenAI::Client.new.vector_stores.create(parameters: {})["id"]
      end
    end

    let(:filename) { "text.txt" }
    let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
    let(:upload_purpose) { "assistants" }
    let(:file_id) do
      VCR.use_cassette("#{cassette} file setup") do
        OpenAI::Client.new.files.upload(parameters: { file: file, purpose: upload_purpose })["id"]
      end
    end

    let(:file_batch_id) do
      VCR.use_cassette("#{cassette} vector_store_file_batch setup") do
        OpenAI::Client.new.vector_store_file_batches.create(
          vector_store_id: vector_store_id,
          parameters: { file_ids: [file_id] }
        )["id"]
      end
    end

    describe "#list" do
      let(:cassette) { "vector_store_file_batches list" }
      let(:response) do
        OpenAI::Client.new.vector_store_file_batches.list(vector_store_id: vector_store_id,
                                                          id: file_batch_id)
      end

      before { file_batch_id }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response.dig("data", 0, "object")).to eq("vector_store.file")
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "vector_store_file_batches retrieve" }
      let(:response) do
        OpenAI::Client.new.vector_store_file_batches.retrieve(vector_store_id: vector_store_id,
                                                              id: file_batch_id)
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("vector_store.file_batch")
        end
      end
    end

    describe "#create" do
      let(:cassette) { "vector_store_file_batches create" }
      let(:response) do
        OpenAI::Client.new.vector_store_file_batches.create(
          vector_store_id: vector_store_id,
          parameters: { file_ids: [file_id] }
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq "vector_store.file_batch"
        end
      end
    end

    describe "#cancel" do
      let(:cassette) { "vector_store_file_batches cancel" }
      let(:response) do
        OpenAI::Client.new.vector_store_file_batches.cancel(vector_store_id: vector_store_id,
                                                            id: file_batch_id)
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq "vector_store.file_batch"
        end
      end
    end
  end
end
