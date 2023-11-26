RSpec.describe OpenAI::Client do
  describe "#run_steps" do
    let(:thread_id) do
      VCR.use_cassette("#{cassette} thread setup") do
        OpenAI::Client.new.threads.create(parameters: {})["id"]
      end
    end
    let(:assistant_id) do
      VCR.use_cassette("#{cassette} assistant setup") do
        OpenAI::Client.new.assistants.create(
          parameters: {
            model: "gpt-4",
            name: "OpenAI-Ruby test assistant"
          }
        )["id"]
      end
    end
    let(:run_id) do
      VCR.use_cassette("#{cassette} run setup") do
        OpenAI::Client.new.runs.create(
          thread_id: thread_id,
          parameters: {
            assistant_id: assistant_id
          }
        )["id"]
      end
    end

    describe "#list" do
      let(:cassette) { "run_steps list" }
      let(:response) do
        OpenAI::Client.new.run_steps.list(
          thread_id: thread_id,
          run_id: run_id
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("list")
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "run_steps retrieve" }
      let(:response) do
        OpenAI::Client.new.run_steps.retrieve(
          thread_id: thread_id,
          run_id: run_id,
          id: "123"
        )
      end

      it "returns the correct error" do
        VCR.use_cassette(cassette) do
          response
        rescue StandardError => e
          expect(e.response.dig(:body, "error", "message")).to include("No run step found")
        end
      end
    end
  end
end
