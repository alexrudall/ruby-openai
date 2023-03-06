RSpec.describe OpenAI::Client do
  describe "#finetunes", :vcr do
    let(:filename) { "sentiment.jsonl" }
    let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
    let!(:file_id) do
      response = VCR.use_cassette("finetunes files upload ") do
        OpenAI::Client.new.upload_file(parameters: { file: file, purpose: "fine-tune" })
      end
      JSON.parse(response.body)["id"]
    end
    let(:model) { "ada" }
    let!(:create_response) do
      VCR.use_cassette("#{cassette} create") do
        OpenAI::Client.new.create_finetunes(
          parameters: {
            training_file: file_id,
            model: model
          }
        )
      end
    end
    let(:create_id) { create_response.parsed_response["id"] }

    describe "#create_finetunes" do
      let(:cassette) { "finetunes" }

      it "succeeds" do
        expect(create_response.parsed_response["object"]).to eq("fine-tune")
      end
    end

    describe "#finetunes" do
      let(:cassette) { "finetunes list" }
      let(:response) { OpenAI::Client.new.finetunes }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          r = JSON.parse(response.body)
          expect(r["data"][0]["object"]).to eq("fine-tune")
        end
      end
    end

    describe "#finetune" do
      let(:cassette) { "finetunes retrieve" }
      let(:response) { OpenAI::Client.new.finetune(id: create_id) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          r = JSON.parse(response.body)
          expect(r["object"]).to eq("fine-tune")
        end
      end
    end

    describe "#cancel" do
      let(:cassette) { "finetunes cancel" }
      let(:response) { OpenAI::Client.new.cancel_finetune(id: create_id) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          r = JSON.parse(response.body)
          expect(r["id"]).to eq(create_id)
          expect(r["status"]).to eq("cancelled")
        end
      end
    end

    describe "#events" do
      let(:cassette) { "finetunes events" }
      let(:response) { OpenAI::Client.new.events(id: create_id) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          r = JSON.parse(response.body)
          expect(r["data"][0]["object"]).to eq("fine-tune-event")
        end
      end
    end

    describe "#delete_finetunes" do
      let(:cassette) { "finetunes delete" }
      let(:retrieve_cassette) { "#{cassette} retrieve" }
      let(:response) { OpenAI::Client.new.delete_finetune(fine_tuned_model: "abc") }

      # It takes too long to fine-tune a model so we can delete it when running the test suite
      # against the live API. Instead, we just check that the API returns an error.
      it "returns an error" do
        VCR.use_cassette(cassette) do
          r = JSON.parse(response.body)
          expect(r.dig("error", "message")).to eq("That model does not exist")
        end
      end

      context "when passing a fine-tune ID instead of the model name" do
        it "raises an error" do
          expect do
            OpenAI::Client.new.delete_finetune(fine_tuned_model: "ft-abc")
          end.to raise_error(ArgumentError)
        end
      end
    end

    describe "#completions" do
      let(:prompt) { "I love Mondays" }
      let(:cassette) { "finetune completions #{prompt}".downcase }
      let(:model) { "ada:ft-user-jxm65ijkzc1qrfhc0ij8moic-2021-12-11-20-11-52" }
      let(:response) do
        OpenAI::Client.new.completions(
          parameters: {
            model: model,
            prompt: prompt
          }
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(JSON.parse(response.body)["model"]).to eq(model)
        end
      end
    end
  end
end
