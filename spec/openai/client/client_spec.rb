RSpec.describe OpenAI::Client do
  let(:default_timeout) { OpenAI::Configuration::DEFAULT_REQUEST_TIMEOUT }

  it "can be initialized" do
    expect { OpenAI::Client.new }.not_to raise_error
  end

  describe ".get" do
    it "passes timeout as param" do
      expect_any_instance_of(Faraday::Connection).to receive(:get).with(
        any_args,
        hash_including(timeout: default_timeout)
      )
      OpenAI::Client.get(path: "/abc")
    end
  end

  describe ".json_post" do
    it "passes timeout as param" do
      expect_any_instance_of(Faraday::Connection).to receive(:post).with(
        any_args,
        hash_including(timeout: default_timeout)
      )
      OpenAI::Client.json_post(path: "/abc", parameters: { foo: :bar })
    end
  end

  describe ".to_json_stream" do
    context "with a proc" do
      let(:user_proc) { proc { |x| x } }
      let(:stream) { OpenAI::Client.to_json_stream(user_proc: user_proc) }

      it "returns a proc" do
        expect(stream).to be_a(Proc)
      end

      context "when called with a string containing a single JSON object" do
        it "calls the user proc with the data parsed as JSON" do
          expect(user_proc).to receive(:call).with(JSON.parse('{"foo": "bar"}'))
          stream.call('data: { "foo": "bar" }')
        end
      end

      context "when called with string containing more than one JSON object" do
        it "calls the user proc for each data parsed as JSON" do
          expect(user_proc).to receive(:call).with(JSON.parse('{"foo": "bar"}'))
          expect(user_proc).to receive(:call).with(JSON.parse('{"baz": "qud"}'))

          stream.call(<<-CHUNK)
            data: { "foo": "bar" }

            data: { "baz": "qud" }

            data: [DONE]

          CHUNK
        end
      end

      context "when called with a string that does not even resemble a JSON object" do
        let(:bad_examples) { ["", "foo", "data: ", "data: foo"] }

        it "does not call the user proc" do
          bad_examples.each do |chunk|
            expect(user_proc).to_not receive(:call)
            stream.call(chunk)
          end
        end
      end

      context "when called with a string containing that looks like a JSON object but is invalid" do
        let(:chunk) do
          <<-CHUNK
            data: { "foo": "bar" }
            data: { BAD ]:-> JSON }
          CHUNK
        end

        it "does not raise an error" do
          expect(user_proc).to receive(:call).with(JSON.parse('{"foo": "bar"}'))

          expect do
            stream.call(chunk)
          end.to_not raise_error(JSON::ParserError)
        end
      end

      context "when called with a string containing an error" do
        let(:chunk) do
          <<-CHUNK
            data: { "foo": "bar" }
            error: { "message": "A bad thing has happened!" }
          CHUNK
        end

        it "does not raise an error" do
          expect(user_proc).to receive(:call).with(JSON.parse('{ "foo": "bar" }'))
          expect(user_proc).to receive(:call).with(
            JSON.parse('{ "message": "A bad thing has happened!" }')
          )

          expect do
            stream.call(chunk)
          end.to_not raise_error(JSON::ParserError)
        end
      end
    end
  end

  describe ".to_json" do
    context "with a jsonl string" do
      let(:body) { "{\"prompt\":\":)\"}\n{\"prompt\":\":(\"}\n" }
      let(:parsed) { OpenAI::Client.to_json(body) }

      it { expect(parsed).to eq([{ "prompt" => ":)" }, { "prompt" => ":(" }]) }
    end
  end

  describe ".multipart_post" do
    it "passes timeout as param to httparty" do
      expect_any_instance_of(Faraday::Connection).to receive(:post).with(
        any_args,
        hash_including(timeout: default_timeout)
      )
      OpenAI::Client.multipart_post(path: "/abc")
    end
  end

  describe ".delete" do
    it "passes timeout as param to httparty" do
      expect_any_instance_of(Faraday::Connection).to receive(:delete).with(
        any_args,
        hash_including(timeout: default_timeout)
      )
      OpenAI::Client.delete(path: "/abc")
    end
  end
end
