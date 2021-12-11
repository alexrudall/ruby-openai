RSpec.describe OpenAI::Client do
  describe "#codex: codex engines" do
    context "with a prompt and max_tokens", :vcr do
      let(:prompt) { "def hello_world\nputs" }
      let(:max_tokens) { 5 }

      let(:response) do
        OpenAI::Client.new.completions(
          engine: engine,
          parameters: {
            prompt: prompt,
            max_tokens: max_tokens
          }
        )
      end
      let(:text) { JSON.parse(response.body)["choices"][0]["text"] }
      let(:cassette) { "#{engine} completions #{prompt}".downcase }

      context "with engine: davinci-codex" do
        let(:engine) { "davinci-codex" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(text.split.empty?).to eq(false)
          end
        end
      end

      context "with engine: cushman-codex" do
        let(:engine) { "cushman-codex" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(text.split.empty?).to eq(false)
          end
        end
      end
    end
  end
end
