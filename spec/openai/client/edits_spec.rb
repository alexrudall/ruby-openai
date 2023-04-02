RSpec.describe OpenAI::Client do
  describe "#edits", :vcr do
    let(:input) { "There are 7 days in a wek, and between 28 and 31 in a month." }
    let(:instruction) { "Fix the misspelled word 'week'" }
    let(:cassette) { "edits #{model} #{input}".downcase }
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
          expect(JSON.parse(response.body).dig("choices", 0, "text").downcase).to include("week")
        end
      end
    end
  end
end
