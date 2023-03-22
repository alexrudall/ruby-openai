RSpec.describe OpenAI::Client do
  it "can be initialized" do
    expect { OpenAI::Client.new }.not_to raise_error
  end

  describe ".get" do
    it "passes timeout as param to httparty" do
      expect(HTTParty).to receive(:get).with(any_args, hash_including(timeout: 60))
      OpenAI::Client.get(path: "abc")
    end
  end

  describe ".json_post" do
    it "passes timeout as param to httparty" do
      expect(HTTParty).to receive(:post).with(any_args, hash_including(timeout: 60))
      OpenAI::Client.json_post(path: "abc", parameters: { foo: :bar })
    end
  end

  describe ".multipart_post" do
    it "passes timeout as param to httparty" do
      expect(HTTParty).to receive(:post).with(any_args, hash_including(timeout: 60))
      OpenAI::Client.multipart_post(path: "abc")
    end
  end

  describe ".delete" do
    it "passes timeout as param to httparty" do
      expect(HTTParty).to receive(:delete).with(any_args, hash_including(timeout: 60))
      OpenAI::Client.delete(path: "abc")
    end
  end
end
