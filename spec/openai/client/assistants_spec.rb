require "pry"

RSpec.describe OpenAI::Client do
  describe "#assistants" do
    describe "#list", :vcr do
      let(:response) { OpenAI::Client.new.assistants.list }
      let(:cassette) { "assistants list" }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response.dig("data", 0, "object")).to eq("assistant")
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "assistants retrieve" }
      let(:response) { OpenAI::Client.new.assistants.retrieve(id: "asst_KfrvKUIYCRCzmwuGe9uuHBHJ") }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("assistant")
        end
      end
    end

    describe "#create" do
      let(:cassette) { "assistants create" }
      let(:response) do
        OpenAI::Client.new.assistants.create(parameters: { model: "gpt-4",
                                                           name: "OpenAI-Ruby test assistant" })
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq "assistant"
          expect(response["id"]).to eq "asst_euYzVdG6KgykipVXq8zhKHwy"
        end
      end
    end

    describe "#delete" do
      let(:cassette) { "assistants delete" }
      let(:response) do
        OpenAI::Client.new.assistants.delete(id: "asst_euYzVdG6KgykipVXq8zhKHwy")
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq "assistant.deleted"
          expect(response["id"]).to eq "asst_euYzVdG6KgykipVXq8zhKHwy"
        end
      end
    end
  end
end
