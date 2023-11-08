RSpec.describe OpenAI::Client do
  describe "#runs" do
    describe "#list" do
      let(:cassette) { "runs list" }
      let(:response) do
        OpenAI::Client.new.runs.list(thread_id: "thread_vd1d6cmJiUkTigpDbCMKBwry")
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response.dig("data", 0, "object")).to eq("thread.run")
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "runs retrieve" }
      let(:response) do
        OpenAI::Client.new.runs.retrieve(thread_id: "thread_vd1d6cmJiUkTigpDbCMKBwry",
                                         id: "run_kINaLRxQg4uZItMP0ExgGwAl")
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("thread.run")
        end
      end
    end

    describe "#create" do
      let(:cassette) { "runs create" }
      let(:response) do
        OpenAI::Client.new.runs.create(
          thread_id: "thread_vd1d6cmJiUkTigpDbCMKBwry",
          parameters: {
            assistant_id: "asst_SGTQseRVgIIasVsVHPDtQNis"
          }
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq "thread.run"
          expect(response["id"]).to eq "run_7OCeXpg2TO4D1566u1fgb71P"
        end
      end
    end

    describe "#submit_tool_outputs" do
      let(:cassette) { "runs submit_tool_outputs" }
      let(:response) do
        OpenAI::Client.new.runs.submit_tool_outputs(
          thread_id: "thread_vd1d6cmJiUkTigpDbCMKBwry",
          run_id: "run_4JBrrlTjuQOngTNayZ5dbsmZ",
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
          expect(response["object"]).to eq "thread.run"
        end
      end
    end
  end
end
