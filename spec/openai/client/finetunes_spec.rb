RSpec.describe OpenAI::Client do
  describe "#finetunes", :vcr do
    let(:filename) { "sentiment.jsonl" }
    let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
    let!(:file_id) do
      response = VCR.use_cassette("finetunes files upload ") do
        OpenAI::Client.new.files.upload(parameters: { file: file, purpose: "fine-tune" })
      end
      response["id"]
    end
    let(:model) { "ada" }
    let!(:create_response) do
      VCR.use_cassette("#{cassette} create") do
        OpenAI::Client.new.finetunes.create(
          parameters: {
            training_file: file_id,
            model: model
          }
        )
      end
    end
    let(:create_id) { create_response["id"] }

    describe "#create" do
      let(:cassette) { "finetunes" }

      it "succeeds" do
        expect(create_response["object"]).to eq("fine-tune")
      end
    end

    describe "#list" do
      let(:cassette) { "finetunes list" }
      let(:response) { OpenAI::Client.new.finetunes.list }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response.dig("data", 0, "object")).to eq("fine-tune")
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "finetunes retrieve" }
      let(:response) { OpenAI::Client.new.finetunes.retrieve(id: create_id) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("fine-tune")
        end
      end
    end

    describe "#cancel" do
      let(:cassette) { "finetunes cancel" }
      let(:response) { OpenAI::Client.new.finetunes.cancel(id: create_id) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["id"]).to eq(create_id)
          expect(response["status"]).to eq("cancelled")
        end
      end
    end

    describe "#events" do
      let(:cassette) { "finetunes events" }
      let(:response) { OpenAI::Client.new.finetunes.events(id: create_id) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["data"][0]["object"]).to eq("fine-tune-event")
        end
      end
    end

    describe "#delete" do
      let(:cassette) { "finetunes delete" }
      let(:retrieve_cassette) { "#{cassette} retrieve" }
      let(:response) { OpenAI::Client.new.finetunes.delete(fine_tuned_model: "abc") }

      # It takes too long to fine-tune a model so we can delete it when running the test suite
      # against the live API. Instead, we just check that the API returns an error.
      it "raises an error" do
        VCR.use_cassette(cassette) do
          expect { response }.to raise_error(Faraday::ResourceNotFound)
        end
      end

      context "when passing a fine-tune ID instead of the model name" do
        it "raises an error" do
          expect do
            OpenAI::Client.new.finetunes.delete(fine_tuned_model: "ft-abc")
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
          expect(response["model"]).to eq(model)
        end
      end
    end
  end
end
