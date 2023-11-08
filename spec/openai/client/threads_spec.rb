RSpec.describe OpenAI::Client do
  describe "#threads" do
    describe "#retrieve" do
      let(:cassette) { "threads retrieve" }
      let(:response) { OpenAI::Client.new.threads.retrieve(id: "thread_yi27pbBPgwZfeoAixPXO6Ak1") }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("thread")
        end
      end
    end

    describe "#create" do
      let(:cassette) { "threads create" }
      let(:response) do
        OpenAI::Client.new.threads.create(parameters: {})
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq "thread"
          expect(response["id"]).to eq "thread_rS55wb8hqGkBrq50D64uRFVl"
        end
      end
    end

    describe "#delete" do
      let(:cassette) { "threads delete" }
      let(:response) do
        OpenAI::Client.new.threads.delete(id: "thread_rS55wb8hqGkBrq50D64uRFVl")
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq "thread.deleted"
          expect(response["id"]).to eq "thread_rS55wb8hqGkBrq50D64uRFVl"
        end
      end
    end
  end
end
