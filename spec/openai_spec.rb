RSpec.describe OpenAI do
  it "has a version number" do
    expect(OpenAI::VERSION).not_to be nil
  end

  describe "#configure" do
    let(:access_token) { "abc123" }
    let(:api_version) { "v2" }
    let(:organization_id) { "def456" }
    let(:request_timeout) { 25 }

    before do
      OpenAI.configure do |config|
        config.access_token = access_token
        config.api_version = api_version
        config.organization_id = organization_id
      end
    end

    it "returns the config" do
      expect(OpenAI.configuration.access_token).to eq(access_token)
      expect(OpenAI.configuration.api_version).to eq(api_version)
      expect(OpenAI.configuration.organization_id).to eq(organization_id)
      expect(OpenAI.configuration.request_timeout).to eq(60)
    end

    context "without an access token" do
      let(:access_token) { nil }

      it "raises an error" do
        expect { OpenAI::Client.new.completions }.to raise_error(OpenAI::ConfigurationError)
      end
    end

    context "with custom timeout" do
      before do
        OpenAI.configure do |config|
          config.request_timeout = request_timeout
        end
      end

      it "returns the config" do
        expect(OpenAI.configuration.access_token).to eq(access_token)
        expect(OpenAI.configuration.api_version).to eq(api_version)
        expect(OpenAI.configuration.organization_id).to eq(organization_id)
        expect(OpenAI.configuration.request_timeout).to eq(request_timeout)
      end
    end
  end
end
