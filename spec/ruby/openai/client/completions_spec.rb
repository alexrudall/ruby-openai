RSpec.describe OpenAI::Client do
  describe "#call" do
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
      let(:text) { JSON.parse(response.body)["choices"].first["text"] }
      let(:cassette) { "#{engine} completions #{prompt}".downcase }

      context "with engine: ada" do
        let(:engine) { "ada" }

        it "can make a request to the OpenAI API" do
          VCR.use_cassette(cassette) do
            expect(text.split(" ").empty?).to eq(false)
          end
        end
      end

      context "with engine: babbage" do
        let(:engine) { "babbage" }

        it "can make a request to the OpenAI API" do
          VCR.use_cassette(cassette) do
            expect(text.split(" ").empty?).to eq(false)
          end
        end
      end

      context "with engine: curie" do
        let(:engine) { "curie" }

        it "can make a request to the OpenAI API" do
          VCR.use_cassette(cassette) do
            expect(text.split(" ").empty?).to eq(false)
          end
        end
      end

      context "with engine: davinci" do
        let(:engine) { "davinci" }

        it "can make a request to the OpenAI API" do
          VCR.use_cassette(cassette) do
            expect(text.split(" ").empty?).to eq(false)
          end
        end
      end
    end
  end
end
