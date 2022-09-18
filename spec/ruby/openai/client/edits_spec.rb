RSpec.describe OpenAI::Client do
  describe "#edits", :vcr do
    let(:input) { "What day of the wek is it?" }
    let(:instruction) { "Fix the spelling mistakes" }
    let(:cassette) { "#{model} moderations #{input}".downcase }
    let(:response) do
      OpenAI::Client.new.edits(
        parameters: {
          model: model,
          input: input,
          instruction: instruction
        }
      )
    end

    context "with model: text-davinci-edit-001" do
      let(:model) { "text-davinci-edit-001" }

      it "edits the input" do
        VCR.use_cassette(cassette) do
          expect(response.dig("choices", 0, "text")).to include("What day of the week is it?")
        end
      end
    end
  end
end
