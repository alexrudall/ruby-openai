RSpec.describe OpenAI do
  it "has a version number" do
    expect(OpenAI::VERSION).not_to be nil
  end

  describe "#configure" do
    let(:access_token) { "abc123" }
    let(:api_version) { "v2" }
    let(:organization_id) { "def456" }
    let(:custom_uri_base) { "ghi789" }
    let(:custom_request_timeout) { 25 }
    let(:custom_headers) { { "My-Custom-Header" => "Some Value" } }

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
      expect(OpenAI.configuration.uri_base).to eq("https://api.openai.com/")
      expect(OpenAI.configuration.request_timeout).to eq(120)
      expect(OpenAI.configuration.custom_headers).to eq({})
    end

    context "without an access token" do
      let(:access_token) { nil }

      it "raises an error" do
        expect { OpenAI::Client.new.completions }.to raise_error(OpenAI::ConfigurationError)
      end
    end

    context "with custom timeout, uri base, and custom headers" do
      before do
        OpenAI.configure do |config|
          config.uri_base = custom_uri_base
          config.request_timeout = custom_request_timeout
          config.custom_headers = custom_headers
        end
      end

      it "returns the config" do
        expect(OpenAI.configuration.access_token).to eq(access_token)
        expect(OpenAI.configuration.api_version).to eq(api_version)
        expect(OpenAI.configuration.organization_id).to eq(organization_id)
        expect(OpenAI.configuration.uri_base).to eq(custom_uri_base)
        expect(OpenAI.configuration.request_timeout).to eq(custom_request_timeout)
        expect(OpenAI.configuration.custom_headers).to eq(custom_headers)
      end
    end
  end
end
