RSpec.describe OpenAI::Client do
  let(:max_prompt_tokens) { 256 }
  let(:max_completion_tokens) { 16 }

  describe "#runs" do
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
            name: "OpenAI-Ruby test assistant",
            instructions: "When asked a question, write and run Ruby code to answer the question"
          }
        )["id"]
      end
    end
    let(:run_id) do
      VCR.use_cassette("#{cassette} run setup") do
        OpenAI::Client.new.runs.create(
          thread_id: thread_id,
          parameters: {
            assistant_id: assistant_id,
            max_prompt_tokens: max_prompt_tokens,
            max_completion_tokens: max_completion_tokens
          }
        )["id"]
      end
    end

    describe "#list" do
      let(:cassette) { "runs list" }
      let(:response) do
        OpenAI::Client.new.runs.list(thread_id: thread_id, parameters: { order: "asc" })
      end

      before { run_id }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response.dig("data", 0, "object")).to eq("thread.run")
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "runs retrieve" }
      let(:response) do
        OpenAI::Client.new.runs.retrieve(thread_id: thread_id,
                                         id: run_id)
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("thread.run")
        end
      end
    end

    describe "#create" do
      let(:stream) { false }
      let(:cassette) { "runs #{'streamed' if stream} create" }
      let(:response) do
        OpenAI::Client.new.runs.create(
          thread_id: thread_id,
          parameters: {
            assistant_id: assistant_id,
            stream: stream,
            max_prompt_tokens: max_prompt_tokens,
            max_completion_tokens: max_completion_tokens
          }
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq "thread.run"
        end
      end

      describe "streaming" do
        let(:chunks) { [] }
        let(:stream) do
          proc do |chunk, _bytesize|
            chunks << chunk
          end
        end

        it "succeeds" do
          VCR.use_cassette(cassette) do
            response
            expect(chunks.dig(0, "id")).not_to be_nil
          end
        end
      end
    end

    describe "#modify" do
      let(:cassette) { "runs modify" }
      let(:response) do
        OpenAI::Client.new.runs.modify(
          id: run_id,
          thread_id: thread_id,
          parameters: {
            metadata: { modified: true }
          }
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect { response }.to raise_error(Faraday::BadRequestError)
        end
      end
    end

    describe "#cancel" do
      let(:cassette) { "runs cancel" }

      context "for a run in progress" do
        let(:response) do
          OpenAI::Client.new.runs.cancel(
            id: run_id,
            thread_id: thread_id
          )
        end

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(response["object"]).to eq "thread.run"
          end
        end
      end
    end

    describe "#create_thread_and_run" do
      let(:cassette) { "runs create thread and run" }
      let(:response) do
        OpenAI::Client.new.runs.create_thread_and_run(
          parameters: {
            assistant_id: assistant_id
          }
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq "thread.run"
        end
      end
    end

    describe "#submit_tool_outputs" do
      let(:cassette) { "runs submit_tool_outputs" }
      let(:response) do
        OpenAI::Client.new.runs.submit_tool_outputs(
          thread_id: thread_id,
          run_id: run_id,
          parameters: {
            tool_outputs: [
              {
                tool_call_id: "call_Vfq8wpokTGewt0ubGCkeuwo1",
                output: "{\"success\": true, \"output\": \"Hello, World\"}"
              }
            ]
          }
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect { response }.to raise_error(Faraday::BadRequestError)
        end
      end
    end
  end
end
