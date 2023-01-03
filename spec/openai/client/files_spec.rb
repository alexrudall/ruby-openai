RSpec.describe OpenAI::Client do
  describe "#files", :vcr do
    let(:filename) { "puppy.jsonl" }
    let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
    let(:id) { "file-pDTosJYQGemK2gpx61qoPN17" }

    describe "#upload" do
      let(:cassette) { "files upload" }
      let(:purpose) { "answers" }
      let(:response) do
        OpenAI::Client.new.files.upload(parameters: { file: file, purpose: purpose })
      end

      context "with a valid JSON lines file" do
        it "succeeds" do
          VCR.use_cassette(cassette) do
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

      it "succeeds" do
        VCR.use_cassette(cassette) do
          r = JSON.parse(response.body)
          expect(r["data"][0]["filename"]).to eq(filename)
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
