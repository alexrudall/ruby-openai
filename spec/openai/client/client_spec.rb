RSpec.describe OpenAI::Client do
  context "with clients with different access tokens" do
    before do
      OpenAI.configure do |config|
        config.access_token = "default"
      end
    end

    it "does not confuse the clients" do
      expect(OpenAI::Client.new.access_token).to eq("default")
      expect(OpenAI::Client.new(access_token: "client1").access_token).to eq("client1")
      expect(OpenAI::Client.new(access_token: "client2").access_token).to eq("client2")
    end
  end
end
