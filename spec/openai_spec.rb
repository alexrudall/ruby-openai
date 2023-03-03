RSpec.describe OpenAI do
  it "has a version number" do
    expect(OpenAI::VERSION).not_to be nil
  end

  it "has default uri base" do
    expect(OpenAI::Configuration.uri_base).not_to be nil
  end

  describe "#configure" do
    let(:access_token) { "abc123" }
    let(:api_version) { "v2" }
    let(:organization_id) { "def456" }
    let(:uri_base) { "ghi789" }

    before do
      OpenAI.configure do |config|
        config.access_token = access_token
        config.api_version = api_version
        config.organization_id = organization_id
        config.uri_base = uri_base
      end
    end

    it "returns the config" do
      expect(OpenAI.configuration.access_token).to eq(access_token)
      expect(OpenAI.configuration.api_version).to eq(api_version)
      expect(OpenAI.configuration.organization_id).to eq(organization_id)
      expect(OpenAI.configuration.uri_base).to eq(uri_base)
    end

    context "without an access token" do
      let(:access_token) { nil }

      it "raises an error" do
        expect { OpenAI::Client.new.completions }.to raise_error(OpenAI::ConfigurationError)
      end
    end
  end
end
