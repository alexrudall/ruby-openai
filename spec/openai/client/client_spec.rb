RSpec.describe OpenAI::Client do
  context "with clients with different access tokens" do
    before do
      OpenAI.configure do |config|
        config.access_token = "default_access_token"
      end
    end

    let!(:default) { OpenAI::Client.new }
    let!(:client1) do
      OpenAI::Client.new(
        access_token: "access_token1",
        request_timeout: 60,
        uri_base: "https://oai.hconeai.com/"
      )
    end
    let!(:client2) do
      OpenAI::Client.new(
        access_token: "access_token2",
        request_timeout: 1,
        uri_base: "https://example.com/"
      )
    end

    it "does not confuse the clients" do
      expect(default.access_token).to eq("default_access_token")
      expect(default.request_timeout).to eq(OpenAI::Configuration::DEFAULT_REQUEST_TIMEOUT)
      expect(default.uri_base).to eq(OpenAI::Configuration::DEFAULT_URI_BASE)

      expect(client1.access_token).to eq("access_token1")
      expect(client1.request_timeout).to eq(60)
      expect(client1.uri_base).to eq("https://oai.hconeai.com/")

      expect(client2.access_token).to eq("access_token2")
      expect(client2.request_timeout).to eq(1)
      expect(client2.uri_base).to eq("https://example.com/")
    end
  end
end
