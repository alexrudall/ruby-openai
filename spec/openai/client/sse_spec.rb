RSpec.describe OpenAI::SSE do
  let(:user_proc) { proc { |x| x } }
  let(:stream) { OpenAI::Client.new.send(:to_json_stream, user_proc: user_proc) }

  let(:sse) { OpenAI::SSE.new(&user_proc) }

  context "given a single JSON object" do
    it "yields the parsed object" do
      expect(user_proc).to receive(:call).with(JSON.parse('{"foo": "bar"}'))
      sse.feed(<<~CHUNK)
        data: { "foo": "bar" }

        data: [DONE]

      CHUNK
      sse.finalize!
    end
  end

  context "given a multiple JSON objects in one chunk" do
    it "yields each parsed JSON object" do
      expect(user_proc).to receive(:call).with(JSON.parse('{"foo": "bar"}'))
      expect(user_proc).to receive(:call).with(JSON.parse('{"baz": "qud"}'))

      sse.feed(<<~CHUNK)
        data: { "foo": "bar" }

        data: { "baz": "qud" }

        data: [DONE]

      CHUNK
      sse.finalize!
    end
  end

  context "given a message that is not valid JSON" do
    it "raises JSON::ParserError" do
      expect do
        sse.feed("data: foo\n\ndata: [DONE]\n\n")
      end.to raise_error(JSON::ParserError)
    end
  end

  context "given an event: message" do
    it "raises InvalidStreamError" do
      expect do
        sse.feed("event: other\n\ndata: [DONE]\n\n")
        sse.finalize!
      end.to raise_error(OpenAI::SSE::InvalidStreamError)
    end
  end

  context "given a message with multiple lines" do
    it "raises InvalidStreamError" do
      # This is actually valid SSE but we choose not to handle
      # it because OpenAI doesn't emit it.
      expect do
        sse.feed("data: a\ndata: b\n\ndata: [DONE]\n\n")
        sse.finalize!
      end.to raise_error(OpenAI::SSE::InvalidStreamError)
    end
  end

  context "given a message with empty data" do
    it "raises JSON::ParserError" do
      expect do
        sse.feed("data: \n\ndata: [DONE]\n\n")
        sse.finalize!
      end.to raise_error(JSON::ParserError)
    end
  end

  context "when given JSON split across chunks" do
    it "yields the data parsed as JSON" do
      expect(user_proc).to receive(:call).with(JSON.parse('{ "foo": "bar" }'))
      sse.feed("data: { \"foo\":")
      sse.feed(" \"bar\" }\n\ndata: [DONE]\n\n")
      sse.finalize!
    end
  end

  context "when missing the [DONE] message" do
    it "raises AbortedStreamError" do
      expect(user_proc).to receive(:call).with(JSON.parse('{ "foo": "bar" }'))
      sse.feed("data: { \"foo\": \"bar\"}\n\n")
      expect { sse.finalize! }.to raise_error(OpenAI::SSE::AbortedStreamError)
    end
  end

  context "when given another message after [DONE]" do
    it "raises InvalidStreamError" do
      expect do
        sse.feed("data: [DONE]\n\ndata: { \"foo\": \"bar\"}\n\n")
      end.to raise_error(OpenAI::SSE::InvalidStreamError)
    end
  end

  context "when given another message after [DONE]" do
    it "raises InvalidStreamError" do
      expect do
        sse.feed("data: [DONE]\n\ndata: [DONE]\n\n")
        sse.finalize!
      end.to raise_error(OpenAI::SSE::InvalidStreamError)
    end
  end

  context "when trailing content exists after [DONE]" do
    it "raises AbortedStreamError" do
      expect do
        sse.feed("data: [DONE]\n\ndat")
        sse.finalize!
      end.to raise_error(OpenAI::SSE::AbortedStreamError)
    end
  end
end
