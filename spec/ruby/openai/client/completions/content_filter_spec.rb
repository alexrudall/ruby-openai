RSpec.describe OpenAI::Client do
  describe "#codex: content-filter engine" do
    context "with a prompt and max_tokens", :vcr do
      let(:prompt) { "A very rude word!" }

      let(:response) do
        OpenAI::Client.new.completions(
          engine: engine,
          parameters: {
            prompt: "<|endoftext|>[#{prompt}]\n--\nLabel:",
            max_tokens: 1,
            temperature: 0.0,
            top_p: 0,
            logprobs: 10
          }
        )
      end
      let(:text) { JSON.parse(response.body)["choices"].first["text"] }
      let(:cassette) { "#{engine} completions #{prompt}".downcase }

      context "with engine: content-filter-alpha" do
        let(:engine) { "content-filter-alpha" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(text.split.empty?).to eq(false)
          end
        end
      end
    end
  end
end
