RSpec.describe OpenAI::Client do
  describe ".initialize" do
    context "when the global configuration includes an access token" do
      let(:global_access_token) { SecureRandom.hex(4) }

      before do
        OpenAI.configure do |config|
          config.access_token = global_access_token
        end
      end

      it "can be initialized with no arguments" do
        expect { OpenAI::Client.new }.not_to raise_error
      end
    end
  end
end
