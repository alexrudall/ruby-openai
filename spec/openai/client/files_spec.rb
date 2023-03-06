RSpec.describe OpenAI::Client do
  describe "#files", :vcr do
    let(:filename) { "sentiment.jsonl" }
    let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
    let(:upload_purpose) { "fine-tune" }
    let(:upload) do
      VCR.use_cassette(upload_cassette) do
        OpenAI::Client.new.upload_file(parameters: { file: file, purpose: upload_purpose })
      end
    end
    let(:upload_id) { upload.parsed_response["id"] }

    describe "#upload_file" do
      let(:upload_cassette) { "files upload" }

      context "with a valid JSON lines file" do
        it "succeeds" do
          expect(upload.parsed_response["filename"]).to eq(filename)
        end
      end

      context "with an invalid file" do
        let(:filename) { File.join("errors", "missing_quote.jsonl") }

        it { expect { upload }.to raise_error(JSON::ParserError) }
      end
    end

    describe "#files" do
      let(:cassette) { "files list" }
      let(:upload_cassette) { "#{cassette} upload" }
      let(:response) { OpenAI::Client.new.files }

      before { upload }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          r = JSON.parse(response.body)
          expect(r["data"].map { |d| d["filename"] }).to include(filename)
        end
      end
    end

    describe "#file" do
      let(:cassette) { "files retrieve" }
      let(:upload_cassette) { "#{cassette} upload" }
      let(:response) { OpenAI::Client.new.file(id: upload_id) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          r = JSON.parse(response.body)
          expect(r["filename"]).to eq(filename)
        end
      end
    end

    describe "#file_content" do
      let(:cassette) { "files content" }
      let(:upload_cassette) { "#{cassette} upload" }
      let(:response) { OpenAI::Client.new.file_content(id: upload_id) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response.body).to include("lakers")
        end
      end
    end

    describe "#delete_file" do
      let(:cassette) { "files delete" }
      let(:upload_cassette) { "#{cassette} upload" }
      let(:retrieve_cassette) { "#{cassette} retrieve" }
      let(:response) do
        OpenAI::Client.new.delete_file(id: upload_id)
      end

      before do
        # We need to check the file has been processed by OpenAI
        # before we can delete it.
        retrieved = VCR.use_cassette(retrieve_cassette) do
          OpenAI::Client.new.file(id: upload_id)
        end
        tries = 0
        until retrieved.parsed_response["status"] == "processed"
          raise "File not processed after 10 tries" if tries > 10

          sleep(1)
          retrieved = VCR.use_cassette(retrieve_cassette, record: :all) do
            OpenAI::Client.new.file(id: upload_id)
          end
          tries += 1
        end
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          r = JSON.parse(response.body)
          expect(r["id"]).to eq(upload_id)
          expect(r["deleted"]).to eq(true)
        end
      end
    end
  end
end
