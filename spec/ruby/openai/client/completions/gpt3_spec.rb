RSpec.describe OpenAI::Client do
  describe "#completions: GPT-3 engines" do
    context "with a prompt and max_tokens", :vcr do
      let(:prompt) { "Once upon a time" }
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

      context "with engine: text-ada-001" do
        let(:engine) { "text-ada-001" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(text.split.empty?).to eq(false)
          end
        end
      end

      context "with engine: text-babbage-001" do
        let(:engine) { "text-babbage-001" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(text.split.empty?).to eq(false)
          end
        end
      end

      context "with engine: text-curie-001" do
        let(:engine) { "text-curie-001" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(text.split.empty?).to eq(false)
          end
        end
      end

      context "with engine: text-davinci-001" do
        let(:engine) { "text-davinci-001" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(text.split.empty?).to eq(false)
          end
        end
      end
    end
  end
end
