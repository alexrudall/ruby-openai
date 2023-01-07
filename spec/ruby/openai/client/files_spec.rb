RSpec.describe OpenAI::Client do
  describe "#files", :vcr do
    let(:filename) { "puppy.jsonl" }
    let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
    let(:id) { "file-pDTosJYQGemK2gpx61qoPN17" }
    let(:upload_cassette) { "files upload" }
    let(:upload_purpose) { "answers" }

    describe "#upload" do
      let(:response) do
        OpenAI::Client.new.files.upload(parameters: { file: file, purpose: upload_purpose })
      end

      context "with a valid JSON lines file" do
        it "succeeds" do
          VCR.use_cassette(upload_cassette) do
            r = JSON.parse(response.body)
            expect(r["filename"]).to eq(filename)
          end
        end
      end

      context "with an invalid file" do
        let(:filename) { File.join("errors", "missing_quote.jsonl") }

        it { expect { response }.to raise_error(JSON::ParserError) }
      end
    end

    describe "#list" do
      let(:cassette) { "files list" }
      let(:response) { OpenAI::Client.new.files.list }

      before do
        VCR.use_cassette(upload_cassette) do
          OpenAI::Client.new.files.upload(parameters: { file: file, purpose: upload_purpose })
        end
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          r = JSON.parse(response.body)
          expect(r["data"].map { |d| d["filename"] }).to include(filename)
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "files retrieve" }
      let(:response) { OpenAI::Client.new.files.retrieve(id: id) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          r = JSON.parse(response.body)
          expect(r["filename"]).to eq(filename)
        end
      end
    end

    describe "#delete" do
      let(:cassette) { "files delete" }
      let(:response) { OpenAI::Client.new.files.delete(id: id) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          r = JSON.parse(response.body)
          expect(r["id"]).to eq(id)
          expect(r["deleted"]).to eq(true)
        end
      end
    end
  end
end
