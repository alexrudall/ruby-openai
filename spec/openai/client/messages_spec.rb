RSpec.describe OpenAI::Client do
  describe "#messages" do
    let(:thread_id) do
      VCR.use_cassette("#{cassette} thread setup") do
        OpenAI::Client.new.threads.create(parameters: {})["id"]
      end
    end
    let(:message_id) do
      VCR.use_cassette("#{cassette} message setup") do
        OpenAI::Client.new.messages.create(
          thread_id: thread_id,
          parameters: {
            role: "user",
            content: "Can you help me write an API library to interact with the OpenAI API please?"
          }
        )["id"]
      end
    end

    describe "#retrieve" do
      let(:cassette) { "messages retrieve" }
      let(:response) do
        OpenAI::Client.new.messages.retrieve(thread_id: thread_id, id: message_id)
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("thread.message")
        end
      end
    end

    describe "#create" do
      let(:cassette) { "messages create" }
      let(:response) do
        OpenAI::Client.new.messages.create(
          thread_id: thread_id,
          parameters: {
            role: "user",
            content: "Can you help me write an API library to interact with the OpenAI API please?"
          }
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq "thread.message"
        end
      end
    end

    describe "#modify" do
      let(:cassette) { "messages modify" }
      let(:response) do
        OpenAI::Client.new.messages.modify(
          id: message_id,
          thread_id: thread_id,
          parameters: {
            metadata: { modified: true }
          }
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq "thread.message"
        end
      end
    end
  end
end
