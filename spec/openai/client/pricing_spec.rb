RSpec.describe OpenAI::Pricing do
  COSTS = {
    "gpt-4o" => {input: 2.50, cached_input: 1.25, output: 10.0, audio_input: nil, audio_output: nil},
    "gpt-4o-audio-preview" => {input: 2.5, cached_input: 1.25, output: 10.0, audio_input: 40.0, audio_output: 80.0}
  }

  describe ".calculate" do
    context "with invalid inputs" do
      it "returns empty hash when model is nil" do
        response = described_class.new.calculate({"model" => nil}, COSTS)
        expect(response).to eq({})
      end

      it "returns empty hash when model is empty" do
        response = described_class.new.calculate({"model" => ""}, COSTS)
        expect(response).to eq({})
      end

      it "returns empty hash when usage is empty" do
        response = described_class.new.calculate({"model" => "gpt-4o", "usage" => {}}, COSTS)
        expect(response).to eq({})
      end

      it "returns empty hash when usage is nil" do
        response = described_class.new.calculate({"model" => "gpt-4o", "usage" => nil}, COSTS)
        expect(response).to eq({})
      end
    end

    context "with text only prompt and completion" do
      it "calculates all costs correctly" do
        response = {
          "model" => "gpt-4o",
          "usage" => {
            "prompt_tokens" => 100,
            "completion_tokens" => 200,
            "total_tokens" => 300,
            "prompt_tokens_details" => {
              "cached_tokens" => 50,
              "audio_tokens" => 0
            },
            "completion_tokens_details" => {
              "reasoning_tokens" => 0,
              "audio_tokens" => 0,
              "accepted_prediction_tokens" => 0,
              "rejected_prediction_tokens" => 0
            }
          }
        }

        result = described_class.new.calculate(response, COSTS)

        expect(result[:prompt_cost]).to eq(0.0001875, )
        expect(result[:completion_cost]).to eq(0.002)
        expect(result[:total_cost]).to eq(0.0021875)

        expect(result.dig(:prompt_cost_details, :cached_cost)).to eq(0.0000625)
        expect(result.dig(:prompt_cost_details, :audio_cost)).to eq(0.0)

        expect(result.dig(:completion_cost_details, :reasoning_cost)).to eq(0)
        expect(result.dig(:completion_cost_details, :audio_cost)).to eq(0)
        expect(result.dig(:completion_cost_details, :accepted_prediction_cost)).to eq(0)
        expect(result.dig(:completion_cost_details, :rejected_prediction_cost)).to eq(0)
      end
    end

    context "with text + audio prompt and completion" do
      it "calculates all costs correctly" do
        response = {
          "model" => "gpt-4o-audio-preview",
          "usage" => {
            "prompt_tokens" => 300,
            "completion_tokens" => 500,
            "total_tokens" => 700,
            "prompt_tokens_details" => {
              "cached_tokens" => 100,
              "audio_tokens" => 100
              #=> 100 non-cached text tokens
            },
            "completion_tokens_details" => {
              "reasoning_tokens" => 100,
              "audio_tokens" => 100,
              "accepted_prediction_tokens" => 100,
              "rejected_prediction_tokens" => 100
              #=> 100 text tokens
            }
          }
        }

        result = described_class.new.calculate(response, COSTS)

        expect(result[:prompt_cost]).to eq(0.004375, )
        expect(result[:completion_cost]).to eq(0.012)
        expect(result[:total_cost]).to eq(0.016375)

        expect(result.dig(:prompt_cost_details, :cached_cost)).to eq(0.000125)
        expect(result.dig(:prompt_cost_details, :audio_cost)).to eq(0.004)

        expect(result.dig(:completion_cost_details, :reasoning_cost)).to eq(0.001)
        expect(result.dig(:completion_cost_details, :audio_cost)).to eq(0.008)
        expect(result.dig(:completion_cost_details, :accepted_prediction_cost)).to eq(0.001)
        expect(result.dig(:completion_cost_details, :rejected_prediction_cost)).to eq(0.001)
      end
    end
  end
end
