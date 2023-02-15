RSpec.describe "compatibility" do
  context "for moved constants" do
    describe "::Ruby::OpenAI::VERSION" do
      it "is mapped to ::OpenAI::VERSION" do
        expect(Ruby::OpenAI::VERSION).to eq(OpenAI::VERSION)
      end
    end

    describe "::Ruby::OpenAI::Error" do
      it "is mapped to ::OpenAI::Error" do
        expect(Ruby::OpenAI::Error).to eq(OpenAI::Error)
        expect(Ruby::OpenAI::Error.new).to be_a(OpenAI::Error)
        expect(OpenAI::Error.new).to be_a(Ruby::OpenAI::Error)
      end
    end

    describe "::Ruby::OpenAI::ConfigurationError" do
      it "is mapped to ::OpenAI::ConfigurationError" do
        expect(Ruby::OpenAI::ConfigurationError).to eq(OpenAI::ConfigurationError)
        expect(Ruby::OpenAI::ConfigurationError.new).to be_a(OpenAI::ConfigurationError)
        expect(OpenAI::ConfigurationError.new).to be_a(Ruby::OpenAI::ConfigurationError)
      end
    end

    describe "::Ruby::OpenAI::Configuration" do
      it "is mapped to ::OpenAI::Configuration" do
        expect(Ruby::OpenAI::Configuration).to eq(OpenAI::Configuration)
        expect(Ruby::OpenAI::Configuration.new).to be_a(OpenAI::Configuration)
        expect(OpenAI::Configuration.new).to be_a(Ruby::OpenAI::Configuration)
      end
    end
  end
end
