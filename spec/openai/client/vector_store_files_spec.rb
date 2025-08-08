RSpec.describe OpenAI::Client do
  describe "#vector_store_files" do
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

    let(:vector_store_file_id) do
      VCR.use_cassette("#{cassette} vector_store_file setup") do
        OpenAI::Client.new.vector_store_files.create(
          vector_store_id: vector_store_id,
          parameters: { file_id: file_id }
        )["id"]
      end
    end

    describe "#list" do
      let(:cassette) { "vector_store_files list" }
      let(:response) do
        OpenAI::Client.new.vector_store_files.list(vector_store_id: vector_store_id)
      end

      before { vector_store_file_id }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response.dig("data", 0, "object")).to eq("vector_store.file")
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "vector_store_files retrieve" }
      let(:response) do
        OpenAI::Client.new.vector_store_files.retrieve(vector_store_id: vector_store_id,
                                                       id: vector_store_file_id)
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("vector_store.file")
        end
      end
    end

    describe "#create" do
      let(:cassette) { "vector_store_files create" }
      let(:response) do
        OpenAI::Client.new.vector_store_files.create(
          vector_store_id: vector_store_id,
          parameters: { file_id: file_id }
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq "vector_store.file"
        end
      end
    end

    describe "#delete" do
      let(:cassette) { "vector_store_files delete" }
      let(:response) do
        OpenAI::Client.new.vector_store_files.delete(vector_store_id: vector_store_id,
                                                     id: vector_store_file_id)
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq "vector_store.file.deleted"
        end
      end
    end
  end
end
