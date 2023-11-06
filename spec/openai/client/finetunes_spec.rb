RSpec.describe OpenAI::Client do
  describe "#finetunes", :vcr do
    let(:model) { "gpt-3.5-turbo-0613" }

    describe "#list" do
      let(:cassette) { "finetunes list" }
      let(:response) { OpenAI::Client.new.finetunes.list }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response.dig("data", 0, "object")).to eq("fine_tuning.job")
        end
      end
    end

    describe "#create" do
      let(:filename) { "sarcastic.jsonl" }
      let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
      let(:cassette) { "finetunes" }
      let(:upload_id) do
        response = VCR.use_cassette("finetunes files upload") do
          OpenAI::Client.new.files.upload(parameters: { file: file, purpose: "fine-tune" })
        end
        response["id"]
      end
      let(:retrieve_cassette) { "#{cassette} retrieve for create" }
      let(:file_id) do
        VCR.use_cassette(retrieve_cassette) do
          OpenAI::Client.new.files.retrieve(id: upload_id)
        end

        upload_id
      end
      let(:response) do
        VCR.use_cassette("#{cassette} create") do
          OpenAI::Client.new.finetunes.create(
            parameters: {
              training_file: file_id,
              model: model
            }
          )
        end
      end

      it "succeeds" do
        expect(response["object"]).to eq("fine_tuning.job")
      end
    end

    describe "#retrieve" do
      let(:cassette) { "finetunes retrieve" }
      let(:response) { OpenAI::Client.new.finetunes.retrieve(id: 123) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          response
        rescue Faraday::ResourceNotFound => e
          expect(e.response).to include(status: 404)
          expect(e.response.dig(:body, "error", "code")).to eq("fine_tune_not_found")
        else
          raise "Expected to raise Faraday::ResourceNotFound"
        end
      end
    end

    describe "#cancel" do
      let(:cassette) { "finetunes cancel" }
      let(:response) { OpenAI::Client.new.finetunes.cancel(id: 123) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          response
        rescue Faraday::ResourceNotFound => e
          expect(e.response).to include(status: 404)
          expect(e.response.dig(:body, "error", "code")).to eq("fine_tune_not_found")
        else
          raise "Expected to raise Faraday::ResourceNotFound"
        end
      end
    end

    describe "#list_events" do
      let(:cassette) { "finetunes event list" }
      let(:response) { OpenAI::Client.new.finetunes.list_events(id: 123) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          response
        rescue Faraday::ResourceNotFound => e
          expect(e.response).to include(status: 404)
          expect(e.response.dig(:body, "error", "code")).to eq("fine_tune_not_found")
        else
          raise "Expected to raise Faraday::ResourceNotFound"
        end
      end
    end
  end
end
