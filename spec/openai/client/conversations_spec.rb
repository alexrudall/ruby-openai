RSpec.describe OpenAI::Client do
  describe "#conversations" do
    let(:conversation_id) do
      VCR.use_cassette("#{cassette} setup") do
        OpenAI::Client.new.conversations.create(parameters: {})["id"]
      end
    end
    let(:item_id) do
      VCR.use_cassette("#{cassette} item setup") do
        OpenAI::Client.new.conversations.create_items(
          conversation_id: conversation_id,
          parameters: {
            items: [
              {
                type: "message",
                role: "user",
                content: [
                  { type: "input_text", text: "Hello, this is a test item" }
                ]
              }
            ]
          }
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

    describe "#list_items" do
      let(:cassette) { "conversations list items" }
      let(:response) do
        OpenAI::Client.new.conversations.list_items(conversation_id: conversation_id)
      end

      before { item_id }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("list")
        end
      end

      context "with parameters" do
        let(:response) do
          OpenAI::Client.new.conversations.list_items(
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

    describe "#get_item" do
      let(:cassette) { "conversations get item" }
      let(:response) do
        OpenAI::Client.new.conversations.get_item(
          conversation_id: conversation_id,
          item_id: item_id
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("conversation.item")
        end
      end
    end

    describe "#create_items" do
      let(:cassette) { "conversations create items" }
      let(:response) do
        OpenAI::Client.new.conversations.create_items(
          conversation_id: conversation_id,
          parameters: {
            items: [
              {
                type: "message",
                role: "user",
                content: [
                  { type: "input_text", text: "Hello!" }
                ]
              },
              {
                type: "message",
                role: "assistant",
                content: [
                  { type: "input_text", text: "How are you?" }
                ]
              }
            ]
          }
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("conversation.item")
        end
      end

      context "with multiple items" do
        let(:response) do
          OpenAI::Client.new.conversations.create_items(
            conversation_id: conversation_id,
            parameters: {
              items: [
                {
                  type: "message",
                  role: "user",
                  content: [
                    { type: "input_text", text: "Hello!" }
                  ]
                },
                {
                  type: "message",
                  role: "user",
                  content: [
                    { type: "input_text", text: "How are you?" }
                  ]
                }
              ]
            }
          )
        end

        it "succeeds with multiple items" do
          VCR.use_cassette(cassette) do
            expect(response["object"]).to eq("conversation.item")
          end
        end
      end
    end

    describe "#delete_item" do
      let(:cassette) { "conversations delete item" }
      let(:response) do
        OpenAI::Client.new.conversations.delete_item(
          conversation_id: conversation_id,
          item_id: item_id
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("conversation.item.deleted")
        end
      end
    end
  end
end
