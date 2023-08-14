RSpec.describe OpenAI::Client do
  describe "#token_count" do
    let(:messages) { [
      { content: "Red is my favorite color." },
      { content: "You miss 100% of the shots you don't take." },
      { content: "Ingredients for banana bread can include 1 egg or 3 eggs." },
      { content: "Egg is not a necessary ingredient." }
    ]}
    let(:client) { OpenAI::Client.new }
    let(:model) { nil }
    let(:token_count) do
      parameters = { messages: messages }
      parameters[:model] = model if model
      client.token_count(parameters: parameters)
    end

    context "without tiktoken" do
      context "without model" do
        it "counts tokens naively" do
          expect(client.class).to receive(:tiktoken_defined?).and_return(false)
          expect(token_count).to eq(41)
        end
      end

      context "with model" do
        let(:model) { "model_name_does_not_matter" }
        it "counts tokens naively" do
          expect(client.class).to receive(:tiktoken_defined?).and_return(false)
          expect(token_count).to eq(41)
        end
      end
    end

    context "with tiktoken" do
      require 'tiktoken_ruby'

      it "recognizes tiktoken" do
        expect(client.class.tiktoken_defined?).to eq(true)
      end

      context "with davinci" do
        let(:model) { "davinci" }
        it "counts tokens" do
          expect(token_count).to eq(37)
        end
      end

      context "with gpt-3.5" do
        let(:model) { "gpt-3.5-turbo" }
        it "counts tokens" do
          expect(token_count).to eq(40)
        end
      end
    end
  end
end
