RSpec.describe OpenAI::Client do
  describe "#completions: GPT-3 models" do
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
      let(:text) { JSON.parse(response.body)["choices"][0]["text"] }
      let(:cassette) { "#{model} completions #{prompt}".downcase }

      context "with model: text-ada-001" do
        let(:model) { "text-ada-001" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(text.split.empty?).to eq(false)
          end
        end
      end

      context "with model: text-babbage-001" do
        let(:model) { "text-babbage-001" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(text.split.empty?).to eq(false)
          end
        end
      end

      context "with model: text-curie-001" do
        let(:model) { "text-curie-001" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(text.split.empty?).to eq(false)
          end
        end
      end

      context "with model: text-davinci-001" do
        let(:model) { "text-davinci-001" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(text.split.empty?).to eq(false)
          end
        end
      end
    end
  end
end
