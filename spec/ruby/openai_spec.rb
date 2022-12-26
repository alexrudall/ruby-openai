RSpec.describe Ruby::OpenAI do
  it "has a version number" do
    expect(Ruby::OpenAI::VERSION).not_to be nil
  end

  describe "#configure" do
    let(:access_token) { "abc123" }
    let(:organization_id) { "def456" }

    before do
      Ruby::OpenAI.configure do |config|
        config.access_token = access_token
        config.organization_id = organization_id
      end
    end

    it "returns the tokens" do
      expect(Ruby::OpenAI.configuration.access_token).to eq(access_token)
      expect(Ruby::OpenAI.configuration.organization_id).to eq(organization_id)
    end
  end
end
