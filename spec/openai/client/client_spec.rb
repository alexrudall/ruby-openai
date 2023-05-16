RSpec.describe OpenAI::Client do
  context "with clients with different access tokens" do
    before do
      OpenAI.configure do |config|
        config.access_token = "default_access_token"
        config.uri_base = "https://api.openai.com"
      end
    end

    it "does not confuse the clients" do
      default = OpenAI::Client.new
      client1 = OpenAI::Client.new(access_token: "access_token1", uri_base: "https://oai.hconeai.com/")
      client2 = OpenAI::Client.new(access_token: "access_token2", uri_base: "https://example.com")

      expect(default.access_token).to eq("default_access_token")
      expect(default.uri_base).to eq("https://api.openai.com")

      expect(client1.access_token).to eq("access_token1")
      expect(client1.uri_base).to eq("https://oai.hconeai.com/")

      expect(client2.access_token).to eq("access_token2")
      expect(client2.uri_base).to eq("https://example.com")
    end
  end
end
