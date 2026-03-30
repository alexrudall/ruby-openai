RSpec.describe OpenAI::Stream do
  let(:user_proc) { proc { |data, event| [data, event] } }
  let(:stream) { OpenAI::Stream.new(user_proc: user_proc) }
  let(:bytes) { 0 }
  let(:env) { Faraday::Env.new.tap { |env| env.status = 200 } }

  describe "#call" do
    context "with a proc" do
      context "when called with a string containing a single JSON object" do
        it "calls the user proc with the data parsed as JSON" do
          expect(user_proc).to receive(:call)
            .with(
              JSON.parse('{"foo": "bar"}'),
              "event.test"
            )

          stream.call(<<~CHUNK, bytes, env)
            event: event.test
            data: { "foo": "bar" }

            #
          CHUNK
        end
      end

      context "when called with a string containing more than one JSON object" do
        it "calls the user proc for each data parsed as JSON" do
          expect(user_proc).to receive(:call)
            .with(
              JSON.parse('{"foo": "bar"}'),
              "event.test.first"
            )
          expect(user_proc).to receive(:call)
            .with(
              JSON.parse('{"baz": "qud"}'),
              "event.test.second"
            )

          stream.call(<<~CHUNK, bytes, env)
            event: event.test.first
            data: { "foo": "bar" }

            event: event.test.second
            data: { "baz": "qud" }

            event: event.complete
            data: [DONE]

            #
          CHUNK
        end
      end

      context "when called with string containing invalid JSON" do
        let(:chunk) do
          <<~CHUNK
            event: event.test
            data: { "foo": "bar" }

            data: NOT JSON

            #
          CHUNK
        end

        it "raise an error" do
          expect(user_proc).to receive(:call)
            .with(
              JSON.parse('{"foo": "bar"}'),
              "event.test"
            )

          expect do
            stream.call(chunk, bytes, env)
          end.to raise_error(JSON::ParserError)
        end
      end

      context "when called with JSON split across chunks" do
        it "calls the user proc with the data parsed as JSON" do
          expect(user_proc).to receive(:call)
            .with(
              JSON.parse('{ "foo": "bar" }'),
              "event.test"
            )

          expect do
            stream.call("event: event.test\n", bytes, env)
            stream.call("data: { \"foo\":", bytes, env)
            stream.call(" \"bar\" }\n\n", bytes, env)
          end.not_to raise_error
        end
      end

      context "with a call method that only takes one argument" do
        let(:user_proc) { proc { |data| data } }

        it "succeeds" do
          expect(user_proc).to receive(:call).with(JSON.parse('{"foo": "bar"}'))

          stream.call(<<~CHUNK, bytes, env)
            event: event.test
            data: { "foo": "bar" }

            #
          CHUNK
        end
      end

      context "when the response status is not 200" do
        let(:error_env) do
          Faraday::Env.new.tap do |env|
            env.status = 401
            env.response = Faraday::Response.new
          end
        end

        it "does not call the user proc" do
          expect(user_proc).not_to receive(:call)

          stream.call('{"error": "unauthorized"}', bytes, error_env)
        end

        it "preserves the error body for the middleware stack" do
          stream.call('{"error": ', bytes, error_env)
          stream.call('"unauthorized"}', bytes, error_env)

          error_env.response.finish(error_env)

          expect(error_env.body).to eq('{"error": "unauthorized"}')
        end
      end

      context "when called with only 2 arguments (like Faraday 2.1.0)" do
        it "handles the call without env parameter" do
          expect(user_proc).to receive(:call)
            .with(
              JSON.parse('{"foo": "bar"}'),
              "event.test"
            )

          # Faraday 2.1.0 calls with only (chunk, size), not (chunk, size, env)
          expect do
            stream.call(<<~CHUNK, bytes)
              event: event.test
              data: { "foo": "bar" }

              #
            CHUNK
          end.not_to raise_error
        end
      end
    end
  end

  describe "#to_proc" do
    it "returns a proc" do
      expect(stream.to_proc).to be_a(Proc)
    end
  end
end
