RSpec.describe OpenAI::Client do
  describe "#files", :vcr do
    let(:filename) { "sentiment.jsonl" }
    let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
    let(:upload_purpose) { "fine-tune" }
    let(:upload) do
      VCR.use_cassette(upload_cassette) do
        OpenAI::Client.new.files.upload(parameters: { file: file, purpose: upload_purpose })
      end
    end
    let(:upload_id) { upload["id"] }

    describe "#upload" do
      let(:upload_cassette) { "files upload #{cassette_label}" }

      context "with an invalid file" do
        let(:cassette_label) { "unused" }
        let(:filename) { File.join("errors", "missing_quote.jsonl") }

        it { expect { upload }.to raise_error(JSON::ParserError) }
      end

      context "with an invalid purpose" do
        let(:cassette_label) { "invalid purpose" }
        let(:upload_purpose) { "invalid" }

        it "logs a warning" do
          expected_message = "The purpose 'invalid' for file 'sentiment.jsonl' is not in the known "
          expected_message += "purpose list: #{OpenAI::Files::PURPOSES.join(', ')}."

          expect(OpenAI).to receive(:log_message)
            .with("Warning", expected_message, :warn)
            .and_call_original

          allow_any_instance_of(OpenAI::Client).to receive(:multipart_post).and_return({})

          upload
        end
      end

      context "with a `File` instance content" do
        let(:cassette_label) { "file" }
        let(:file) { File.open(File.join(RSPEC_ROOT, "fixtures/files", filename)) }

        it "succeeds" do
          expect(upload["filename"]).to eq(filename)
        end
      end

      context "with a `StringIO` instance content" do
        let(:cassette_label) { "stringio" }
        let(:file) { StringIO.new(File.read(File.join(RSPEC_ROOT, "fixtures/files", filename))) }

        it "succeeds" do
          expect(upload["filename"]).to eq("local.path")
        end
      end

      context "with a vision purpose" do
        let(:cassette_label) { "vision" }
        let(:filename) { "image.png" }
        let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
        let(:upload_purpose) { "vision" }

        it "succeeds" do
          expect(upload["filename"]).to eq(filename)
        end
      end
    end

    describe "#list" do
      let(:cassette) { "files list" }
      let(:upload_cassette) { "#{cassette} upload" }
      let(:response) { OpenAI::Client.new.files.list(parameters: { purpose: "fine-tune" }) }

      before { upload }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["data"].map { |d| d["filename"] }).to include(filename)
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "files retrieve" }
      let(:upload_cassette) { "#{cassette} upload" }
      let(:response) { OpenAI::Client.new.files.retrieve(id: upload_id) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["filename"]).to eq(filename)
        end
      end
    end

    describe "#content" do
      let(:cassette) { "files content" }
      let(:upload_cassette) { "#{cassette} upload" }
      let(:response) { OpenAI::Client.new.files.content(id: upload_id) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response.dig(1, "prompt")).to include("lakers")
        end
      end
    end

    describe "#delete" do
      let(:cassette) { "files delete" }
      let(:upload_cassette) { "#{cassette} upload" }
      let(:retrieve_cassette) { "#{cassette} retrieve" }
      let(:response) do
        OpenAI::Client.new.files.delete(id: upload_id)
      end

      before do
        # We need to check the file has been processed by OpenAI
        # before we can delete it.
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
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["id"]).to eq(upload_id)
          expect(response["deleted"]).to eq(true)
        end
      end
    end

    describe "#fetch_image" do
      let(:cassette) { "files fetch_image" }
      let(:upload_cassette) { "#{cassette} upload" }
      let(:retrieve_cassette) { "#{cassette} retrieve" }
      let(:filename) { "image.png" }
      let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
      let(:upload_purpose) { "vision" }
      let(:response) { OpenAI::Client.new.files.content(id: upload_id) }

      before do
        # We need to check the file has been processed by OpenAI
        # before we can delete it.
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
      end

      it "succeeds in uploading and retrieving an image" do
        VCR.use_cassette(cassette) do
          expect(response).to be_a(String)
          expect(response.size).to be > 0
        end
      end
    end
  end
end
