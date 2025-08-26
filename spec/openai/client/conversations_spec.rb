RSpec.describe OpenAI::Client do
  describe "#conversations" do
    let(:conversation_id) do
      VCR.use_cassette("#{cassette} setup") do
        OpenAI::Client.new.conversations.create(parameters: {})["id"]
      end
    end
    let(:message_id) do
      VCR.use_cassette("#{cassette} message setup") do
        OpenAI::Client.new.conversations.create_message(
          conversation_id: conversation_id,
          parameters: { content: "Hello, this is a test message" }
        )["id"]
      end
    end

    describe "#list" do
      let(:cassette) { "conversations list" }
      let(:response) { OpenAI::Client.new.conversations.list }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("list")
        end
      end

      context "with parameters" do
        let(:response) do
          OpenAI::Client.new.conversations.list(parameters: { limit: 10 })
        end

        it "succeeds with parameters" do
          VCR.use_cassette(cassette) do
            expect(response["object"]).to eq("list")
          end
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "conversations retrieve" }
      let(:response) { OpenAI::Client.new.conversations.retrieve(id: conversation_id) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("conversation")
        end
      end
    end

    describe "#create" do
      let(:cassette) { "conversations create" }
      let(:response) do
        OpenAI::Client.new.conversations.create(parameters: {})
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("conversation")
        end
      end

      context "with parameters" do
        let(:response) do
          OpenAI::Client.new.conversations.create(
            parameters: { metadata: { purpose: "test" } }
          )
        end

        it "succeeds with parameters" do
          VCR.use_cassette(cassette) do
            expect(response["object"]).to eq("conversation")
          end
        end
      end
    end

    describe "#modify" do
      let(:cassette) { "conversations modify" }
      let(:response) do
        OpenAI::Client.new.conversations.modify(
          id: conversation_id,
          parameters: { metadata: { modified: "true" } }
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("conversation")
        end
      end
    end

    describe "#delete" do
      let(:cassette) { "conversations delete" }
      let(:response) do
        OpenAI::Client.new.conversations.delete(id: conversation_id)
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("conversation.deleted")
        end
      end
    end

    describe "#messages" do
      let(:cassette) { "conversations messages" }
      let(:response) do
        OpenAI::Client.new.conversations.messages(conversation_id: conversation_id)
      end

      before { message_id }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("list")
        end
      end

      context "with parameters" do
        let(:response) do
          OpenAI::Client.new.conversations.messages(
            conversation_id: conversation_id,
            parameters: { limit: 5 }
          )
        end

        it "succeeds with parameters" do
          VCR.use_cassette(cassette) do
            expect(response["object"]).to eq("list")
          end
        end
      end
    end

    describe "#retrieve_message" do
      let(:cassette) { "conversations retrieve message" }
      let(:response) do
        OpenAI::Client.new.conversations.retrieve_message(
          conversation_id: conversation_id,
          message_id: message_id
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("conversation.message")
        end
      end
    end

    describe "#create_message" do
      let(:cassette) { "conversations create message" }
      let(:response) do
        OpenAI::Client.new.conversations.create_message(
          conversation_id: conversation_id,
          parameters: { content: "Hello, this is a test message" }
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("conversation.message")
        end
      end

      context "with additional parameters" do
        let(:response) do
          OpenAI::Client.new.conversations.create_message(
            conversation_id: conversation_id,
            parameters: {
              content: "Hello with metadata",
              metadata: { test: "value" }
            }
          )
        end

        it "succeeds with additional parameters" do
          VCR.use_cassette(cassette) do
            expect(response["object"]).to eq("conversation.message")
          end
        end
      end
    end

    describe "#delete_message" do
      let(:cassette) { "conversations delete message" }
      let(:response) do
        OpenAI::Client.new.conversations.delete_message(
          conversation_id: conversation_id,
          message_id: message_id
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("conversation.message.deleted")
        end
      end
    end
  end
end
