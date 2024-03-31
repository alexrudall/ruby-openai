RSpec.describe OpenAI::Client do
  describe "#completions: gpt-3.5-turbo-instruct" do
    context "with a prompt and max_tokens", :vcr do
      let(:prompt) { "Once upon a time" }
      let(:max_tokens) { 5 }

      let(:response) do
        OpenAI::Client.new.completions(
          parameters: {
            model: model,
            prompt: prompt,
            max_tokens: max_tokens
          }
        )
      end
      let(:text) { response.dig("choices", 0, "text") }
      let(:cassette) { "#{model} completions #{prompt}".downcase }
      let(:model) { "gpt-3.5-turbo-instruct" }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(text.split.empty?).to eq(false)
        end
      end
    end
  end
end
