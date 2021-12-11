RSpec.describe OpenAI::Client do
  describe "#finetunes", :vcr do
    let(:filename) { "sentiment.jsonl" }
    let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
    let!(:file_id) do
      response = VCR.use_cassette("files upload finetunes") do
        OpenAI::Client.new.files.upload(parameters: { file: file, purpose: "fine-tune" })
      end
      JSON.parse(response.body)["id"]
    end
    let(:id) { "ft-ZzqySi12E41glJjrUwaOKhGS" }

    describe "#create" do
      let(:cassette) { "finetunes create" }
      let(:model) { "ada" }
      let(:response) do
        OpenAI::Client.new.finetunes.create(
          parameters: {
            training_file: file_id,
            model: model
          }
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          r = JSON.parse(response.body)
          expect(r["object"]).to eq("fine-tune")
        end
      end
    end

    describe "#list" do
      let(:cassette) { "finetunes list" }
      let(:response) { OpenAI::Client.new.finetunes.list }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          r = JSON.parse(response.body)
          expect(r["data"].first["object"]).to eq("fine-tune")
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "finetunes retrieve" }
      let(:response) { OpenAI::Client.new.finetunes.retrieve(id: id) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          r = JSON.parse(response.body)
          expect(r["object"]).to eq("fine-tune")
        end
      end
    end

    describe "#cancel" do
      let(:cassette) { "finetunes cancel" }
      let(:response) { OpenAI::Client.new.finetunes.cancel(id: id) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          r = JSON.parse(response.body)
          expect(r["id"]).to eq(id)
          expect(r["status"]).to eq("cancelled")
        end
      end
    end

    describe "#events" do
      let(:cassette) { "finetunes events" }
      let(:response) { OpenAI::Client.new.finetunes.events(id: id) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          r = JSON.parse(response.body)
          expect(r["data"].first["object"]).to eq("fine-tune-event")
        end
      end
    end
  end
end
