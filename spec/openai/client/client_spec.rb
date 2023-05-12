RSpec.describe OpenAI::Client do
  context "with clients with different access tokens" do
    before do
      OpenAI.configure do |config|
        config.access_token = "default"
      end
    end

    it "does not confuse the clients" do
      default = OpenAI::Client.new
      client1 = OpenAI::Client.new(access_token: "client1")
      client2 = OpenAI::Client.new(access_token: "client2")

      expect(default.access_token).to eq("default")
      expect(client1.access_token).to eq("client1")
      expect(client2.access_token).to eq("client2")
    end
  end
end
