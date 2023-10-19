RSpec.describe OpenAI::HTTP do
  describe "with an aggressive timeout" do
    let(:timeout_errors) { [Faraday::ConnectionFailed, Faraday::TimeoutError] }
    let(:timeout) { 0 }

    # We disable VCR and WebMock for timeout specs, otherwise VCR will return instant
    # responses when using the recorded responses and the specs will fail incorrectly.
    # The timeout is set to 0, so these specs will never actually hit the API and
    # therefore are still fast and deterministic.
    before do
      VCR.turn_off!
      WebMock.allow_net_connect!
      OpenAI.configuration.request_timeout = timeout
    end

    after do
      VCR.turn_on!
      WebMock.disable_net_connect!
      OpenAI.configuration.request_timeout = OpenAI::Configuration::DEFAULT_REQUEST_TIMEOUT
    end

    describe ".get" do
      let(:response) { OpenAI::Client.new.models.list }

      it "times out" do
        expect { response }.to raise_error do |error|
          expect(timeout_errors).to include(error.class)
        end
      end
    end

    describe ".json_post" do
      let(:response) do
        OpenAI::Client.new.chat(
          parameters: {
            model: "gpt-3.5-turbo",
            messages: [{ role: "user", content: "Hello!" }],
            stream: stream
          }
        )
      end

      context "not streaming" do
        let(:stream) { false }

        it "times out" do
          expect { response }.to raise_error do |error|
            expect(timeout_errors).to include(error.class)
          end
        end
      end

      context "streaming" do
        let(:chunks) { [] }
        let(:stream) do
          proc do |chunk, _bytesize|
            chunks << chunk
          end
        end

        it "times out" do
          expect { response }.to raise_error do |error|
            expect(timeout_errors).to include(error.class)
          end
        end
      end
    end

    describe ".multipart_post" do
      let(:filename) { "sentiment.jsonl" }
      let(:file) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
      let(:upload_purpose) { "fine-tune" }
      let(:response) do
        OpenAI::Client.new.files.upload(
          parameters: { file: file, purpose: upload_purpose }
        )
      end

      it "times out" do
        expect { response }.to raise_error do |error|
          expect(timeout_errors).to include(error.class)
        end
      end
    end

    describe ".delete" do
      let(:response) do
        OpenAI::Client.new.finetunes.delete(fine_tuned_model: "1a")
      end

      it "times out" do
        expect { response }.to raise_error do |error|
          expect(timeout_errors).to include(error.class)
        end
      end
    end
  end

  describe ".to_json_stream" do
    context "with a proc" do
      let(:user_proc) { proc { |x| x } }
      let(:stream) { OpenAI::Client.new.send(:to_json_stream, user_proc: user_proc) }

      it "returns a proc" do
        expect(stream).to be_a(Proc)
      end

      context "when called with a string containing a single JSON object" do
        it "calls the user proc with the data parsed as JSON" do
          expect(user_proc).to receive(:call).with(JSON.parse('{"foo": "bar"}'))
          stream.call(<<~CHUNK)
            data: { "foo": "bar" }

            #
          CHUNK
        end
      end

      context "when called with a string containing more than one JSON object" do
        it "calls the user proc for each data parsed as JSON" do
          expect(user_proc).to receive(:call).with(JSON.parse('{"foo": "bar"}'))
          expect(user_proc).to receive(:call).with(JSON.parse('{"baz": "qud"}'))

          stream.call(<<~CHUNK)
            data: { "foo": "bar" }

            data: { "baz": "qud" }

            data: [DONE]

            #
          CHUNK
        end
      end

      context "when called with string containing invalid JSON" do
        let(:chunk) do
          <<~CHUNK
            data: { "foo": "bar" }

            data: NOT JSON

            #
          CHUNK
        end

        it "raise an error" do
          expect(user_proc).to receive(:call).with(JSON.parse('{"foo": "bar"}'))

          expect do
            stream.call(chunk)
          end.to raise_error(JSON::ParserError)
        end
      end

      context "when OpenAI returns an HTTP error" do
        let(:chunk) { "{\"error\":{\"message\":\"A bad thing has happened!\"}}" }
        let(:env) { Faraday::Env.new(status: 500) }

        it "does not raise an error and calls the user proc with the error parsed as JSON" do
          expect(user_proc).to receive(:call).with(
            {
              "error" => {
                "message" => "A bad thing has happened!"
              }
            }
          )

          expect do
            stream.call(chunk, 0, env)
          end.not_to raise_error
        end
      end

      context "when called with JSON split across chunks" do
        it "calls the user proc with the data parsed as JSON" do
          expect(user_proc).to receive(:call).with(JSON.parse('{ "foo": "bar" }'))
          expect do
            stream.call("data: { \"foo\":")
            stream.call(" \"bar\" }\n\n")
          end.not_to raise_error
        end
      end
    end
  end

  describe ".to_json" do
    context "with a jsonl string" do
      let(:body) { "{\"prompt\":\":)\"}\n{\"prompt\":\":(\"}\n" }
      let(:parsed) { OpenAI::Client.new.send(:to_json, body) }

      it { expect(parsed).to eq([{ "prompt" => ":)" }, { "prompt" => ":(" }]) }
    end
  end

  describe ".uri" do
    let(:path) { "/chat" }
    let(:uri) { OpenAI::Client.new.send(:uri, path: path) }

    it { expect(uri).to eq("https://api.openai.com/v1/chat") }

    context "uri_base without trailing slash" do
      before do
        OpenAI.configuration.uri_base = "https://api.openai.com"
      end

      after do
        OpenAI.configuration.uri_base = "https://api.openai.com/"
      end

      it { expect(uri).to eq("https://api.openai.com/v1/chat") }
    end

    describe "with Azure" do
      before do
        OpenAI.configuration.uri_base = uri_base
        OpenAI.configuration.api_type = :azure
      end

      after do
        OpenAI.configuration.uri_base = "https://api.openai.com/"
        OpenAI.configuration.api_type = nil
      end

      let(:path) { "/chat" }
      let(:uri) { OpenAI::Client.new.send(:uri, path: path) }

      context "with a trailing slash" do
        let(:uri_base) { "https://custom-domain.openai.azure.com/openai/deployments/gpt-35-turbo/" }
        it { expect(uri).to eq("https://custom-domain.openai.azure.com/openai/deployments/gpt-35-turbo/chat?api-version=v1") }
      end

      context "without a trailing slash" do
        let(:uri_base) { "https://custom-domain.openai.azure.com/openai/deployments/gpt-35-turbo" }
        it { expect(uri).to eq("https://custom-domain.openai.azure.com/openai/deployments/gpt-35-turbo/chat?api-version=v1") }
      end
    end
  end

  describe ".headers" do
    before do
      OpenAI.configuration.api_type = :nil
    end

    let(:headers) { OpenAI::Client.new.send(:headers) }

    it {
      expect(headers).to eq({ "Authorization" => "Bearer #{OpenAI.configuration.access_token}",
                              "Content-Type" => "application/json", "OpenAI-Organization" => nil })
    }

    describe "with Azure" do
      before do
        OpenAI.configuration.api_type = :azure
      end

      after do
        OpenAI.configuration.api_type = nil
      end

      let(:headers) { OpenAI::Client.new.send(:headers) }

      it {
        expect(headers).to eq({ "Content-Type" => "application/json",
                                "api-key" => OpenAI.configuration.access_token })
      }
    end
  end
end
