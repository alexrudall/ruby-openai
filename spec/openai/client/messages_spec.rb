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

    describe "#files" do
      let(:cassette) { "messages files" }
      let(:response) do
        OpenAI::Client.new.messages.files(thread_id: thread_id, id: message_id)
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq "list"
        end
      end
    end

    describe "#file" do
      let(:cassette) { "thread message file" }
      let(:filename) { "sarcastic.jsonl" }
      let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
      let(:upload_id) do
        response = VCR.use_cassette("file upload") do
          OpenAI::Client.new.files.upload(parameters: { file: file, purpose: "fine-tune" })
        end
        response["id"]
      end
      let(:message_with_a_file_id) do
        VCR.use_cassette("#{cassette} message setup") do
          OpenAI::Client.new.messages.create(
            thread_id: thread_id,
            parameters: {
              role: "user",
              content: "Can you help me write an API library?",
              file_ids: [upload_id]
            }
          )["id"]
        end
      end
      let(:response) do
        OpenAI::Client.new.messages.file(thread_id: thread_id, id: message_with_a_file_id,
                                         file_id: upload_id)
      end
      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq "thread.message.file"
        end
      end
    end
  end
end
