RSpec.describe OpenAI::Client do
  describe "#run_steps" do
    describe "#list" do
      let(:cassette) { "run_steps list" }
      let(:response) do
        OpenAI::Client.new.run_steps.list(
          thread_id: "thread_vd1d6cmJiUkTigpDbCMKBwry",
          run_id: "run_kINaLRxQg4uZItMP0ExgGwAl"
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response.dig("data", 0, "object")).to eq("thread.run.step")
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "run_steps retrieve" }
      let(:response) do
        OpenAI::Client.new.run_steps.retrieve(
          thread_id: "thread_vd1d6cmJiUkTigpDbCMKBwry",
          run_id: "run_kINaLRxQg4uZItMP0ExgGwAl",
          id: "step_BM4yN3TSI1mm2dbAwHUD0ATS"
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("thread.run.step")
        end
      end
    end
  end
end
