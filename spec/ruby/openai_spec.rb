RSpec.describe Ruby::OpenAI do
  it "has a version number" do
    expect(Ruby::OpenAI::VERSION).not_to be nil
  end

  describe "#configure" do
    let(:access_token) { "abc123" }
    let(:api_version) { "v2" }
    let(:organization_id) { "def456" }

    before do
      Ruby::OpenAI.configure do |config|
        config.access_token = access_token
        config.api_version = api_version
        config.organization_id = organization_id
      end
    end

    it "returns the config" do
      expect(Ruby::OpenAI.configuration.access_token).to eq(access_token)
      expect(Ruby::OpenAI.configuration.api_version).to eq(api_version)
      expect(Ruby::OpenAI.configuration.organization_id).to eq(organization_id)
    end

    context "without an access token" do
      let(:access_token) { nil }

      it "raises an error" do
        expect { OpenAI::Client.new.completions }.to raise_error(Ruby::OpenAI::ConfigurationError)
      end
    end
  end
end
