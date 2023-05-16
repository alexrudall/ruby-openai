RSpec.describe OpenAI::Client do
  context "with clients with different access tokens" do
    before do
      OpenAI.configure do |config|
        config.access_token = "c0_access_token"
      end
    end

    let!(:c0) { OpenAI::Client.new }
    let!(:c1) do
      OpenAI::Client.new(
        access_token: "access_token1",
        organization_id: "organization_id1",
        request_timeout: 60,
        uri_base: "https://oai.hconeai.com/"
      )
    end
    let!(:c2) do
      OpenAI::Client.new(
        access_token: "access_token2",
        organization_id: "organization_id2",
        request_timeout: 1,
        uri_base: "https://example.com/"
      )
    end

    it "does not confuse the clients" do
      expect(c0.access_token).to eq("c0_access_token")
      expect(c0.organization_id).to eq(nil)
      expect(c0.request_timeout).to eq(OpenAI::Configuration::DEFAULT_REQUEST_TIMEOUT)
      expect(c0.uri_base).to eq(OpenAI::Configuration::DEFAULT_URI_BASE)

      expect(c1.access_token).to eq("access_token1")
      expect(c1.organization_id).to eq("organization_id1")
      expect(c1.request_timeout).to eq(60)
      expect(c1.uri_base).to eq("https://oai.hconeai.com/")

      expect(c2.access_token).to eq("access_token2")
      expect(c2.organization_id).to eq("organization_id2")
      expect(c2.request_timeout).to eq(1)
      expect(c2.uri_base).to eq("https://example.com/")
    end

    context "hitting other classes" do
      after do
        c0.files.list
        c1.files.list
        c2.files.list

        c0.finetunes.list
        c1.finetunes.list
        c2.finetunes.list

        c0.images.generate
        c1.images.generate
        c2.images.generate

        c0.models.list
        c1.models.list
        c2.models.list
      end

      it "does not confuse the clients" do
        expect(c0).to receive(:get).with(path: "/files").once
        expect(c1).to receive(:get).with(path: "/files").once
        expect(c2).to receive(:get).with(path: "/files").once

        expect(c0).to receive(:get).with(path: "/fine-tunes").once
        expect(c1).to receive(:get).with(path: "/fine-tunes").once
        expect(c2).to receive(:get).with(path: "/fine-tunes").once

        expect(c0).to receive(:json_post).with(path: "/images/generations", parameters: {}).once
        expect(c1).to receive(:json_post).with(path: "/images/generations", parameters: {}).once
        expect(c2).to receive(:json_post).with(path: "/images/generations", parameters: {}).once

        expect(c0).to receive(:get).with(path: "/models").once
        expect(c1).to receive(:get).with(path: "/models").once
        expect(c2).to receive(:get).with(path: "/models").once
      end
    end
  end
end