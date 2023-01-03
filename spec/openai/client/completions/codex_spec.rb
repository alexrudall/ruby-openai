RSpec.describe OpenAI::Client do
  describe "#codex: codex models" do
    context "with a prompt and max_tokens", :vcr do
      let(:prompt) { "def hello_world\nputs" }
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
      let(:text) { JSON.parse(response.body)["choices"][0]["text"] }
      let(:cassette) { "#{model} completions #{prompt}".downcase }

      context "with model: davinci-codex" do
        let(:model) { "davinci-codex" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(text.split.empty?).to eq(false)
          end
        end
      end

      context "with model: cushman-codex" do
        let(:model) { "cushman-codex" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(text.split.empty?).to eq(false)
          end
        end
      end
    end
  end
end
