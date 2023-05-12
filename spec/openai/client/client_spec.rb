RSpec.describe OpenAI::Client do
  context "with 2 clients with different access tokens" do
    let!(:client1) { OpenAI::Client.new(access_token: "client1") }
    let!(:client2) { OpenAI::Client.new(access_token: "client2") }

    it { expect(client1.access_token).to eq("client1") }
    it { expect(client2.access_token).to eq("client2") }
  end
end
