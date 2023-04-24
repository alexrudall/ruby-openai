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

  describe ".json_parse" do
    context "with a jsonl string" do
      let(:body) { "{\"prompt\":\":)\"}\n{\"prompt\":\":(\"}\n" }
      let(:response) { Faraday::Response.new(body: body) }
      let(:parsed) { OpenAI::Client.json_parse(response) }

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
