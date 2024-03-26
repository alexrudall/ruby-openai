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
    let(:extra_headers) { { "User-Agent" => "OpenAI Ruby Gem #{OpenAI::VERSION}" } }
    let(:api_type) { nil }

    before do
      OpenAI.configure do |config|
        config.access_token = access_token
        config.api_version = api_version
        config.organization_id = organization_id
        config.extra_headers = extra_headers
        config.api_type = api_type
      end
    end

    it "returns the config" do
      expect(OpenAI.configuration.access_token).to eq(access_token)
      expect(OpenAI.configuration.api_version).to eq(api_version)
      expect(OpenAI.configuration.organization_id).to eq(organization_id)
      expect(OpenAI.configuration.uri_base).to eq("https://api.openai.com/")
      expect(OpenAI.configuration.request_timeout).to eq(120)
      expect(OpenAI.configuration.extra_headers).to eq(extra_headers)
    end

    context "without an access token" do
      let(:access_token) { nil }

      it "raises an error" do
        expect { OpenAI::Client.new.chat }.to raise_error(OpenAI::ConfigurationError)
      end
    end

    context "with ollama api_type" do
      let(:access_token) { nil }
      let(:api_type) { :ollama }

      it "does not raises an error" do
        expect { OpenAI::Client.new.chat }.not_to raise_error(OpenAI::ConfigurationError)
      end
    end

    context "with custom timeout and uri base" do
      before do
        OpenAI.configure do |config|
          config.uri_base = custom_uri_base
          config.request_timeout = custom_request_timeout
        end
      end

      it "returns the config" do
        expect(OpenAI.configuration.access_token).to eq(access_token)
        expect(OpenAI.configuration.api_version).to eq(api_version)
        expect(OpenAI.configuration.organization_id).to eq(organization_id)
        expect(OpenAI.configuration.uri_base).to eq(custom_uri_base)
        expect(OpenAI.configuration.request_timeout).to eq(custom_request_timeout)
        expect(OpenAI.configuration.extra_headers).to eq(extra_headers)
      end
    end
  end

  describe "#rough_token_count" do
    context "on a non-String" do
      it "raises an error" do
        expect { OpenAI.rough_token_count([]) }.to raise_error(ArgumentError)
      end
    end

    context "on the empty string" do
      it "returns 0" do
        expect(OpenAI.rough_token_count("")).to eq(0)
      end
    end

    context "on a string" do
      let(:content) { "Red is my favorite color. Egg is not a necessary ingredient." }
      it "estimates tokens" do
        expect(OpenAI.rough_token_count(content)).to eq(15)
      end
    end
  end
end
