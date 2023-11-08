RSpec.describe OpenAI::Client do
  describe "#messages" do
    describe "#retrieve" do
      let(:cassette) { "messages retrieve" }
      let(:response) do
        OpenAI::Client.new.messages.retrieve(thread_id: "thread_vd1d6cmJiUkTigpDbCMKBwry",
                                             id: "msg_jzdSGmyXvRQUPbyA80obyQnn")
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
          thread_id: "thread_vd1d6cmJiUkTigpDbCMKBwry",
          parameters: {
            role: "user",
            content: "Can you help me write an API library to interact with the OpenAI API please?"
          }
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq "thread.message"
          expect(response["id"]).to eq "msg_SfZO3m6lv7beHQBS5DazS6dn"
        end
      end
    end
  end
end
