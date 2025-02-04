# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
module OpenAI
  class Pricing
    class << self
      def costs_table
        @costs_table ||= JSON.parse(File.read(OpenAI.configuration.costs_table_path))
      end
    end

    def self.calculate(response)
      new.calculate(response)
    end

    def calculate(response)
      costs = self.class.costs_table
      model = response["model"]
      usage = response["usage"]
      pricing = costs[model]

      return {} if [model, usage, pricing].any? { |val| val.nil? || val.empty? }

      pricing = pricing.transform_values { |v| (v || 0) / 1_000_000.0 }

      prompt_costs = calculate_prompt_costs(usage, pricing)
      completion_costs = calculate_completion_costs(usage, pricing)

      {
        prompt_cost: prompt_costs[:total],
        completion_cost: completion_costs[:total],
        total_cost: prompt_costs[:total] + completion_costs[:total],
        prompt_cost_details: {
          cached_cost: prompt_costs[:cached],
          audio_cost: prompt_costs[:audio]
        },
        completion_cost_details: {
          reasoning_cost: completion_costs[:reasoning],
          audio_cost: completion_costs[:audio],
          accepted_prediction_cost: completion_costs[:accepted_prediction],
          rejected_prediction_cost: completion_costs[:rejected_prediction]
        }
      }
    end

    private

    def calculate_prompt_costs(usage, pricing)
      details = usage["prompt_tokens_details"] || {}

      cached_tokens = details["cached_tokens"] || 0
      audio_tokens = details["audio_tokens"] || 0
      regular_tokens = usage["prompt_tokens"] - cached_tokens - audio_tokens

      cached_cost = cached_tokens * pricing[:cached_input]
      audio_cost = audio_tokens * pricing[:audio_input]
      regular_cost = regular_tokens * pricing[:input]

      {
        total: cached_cost + audio_cost + regular_cost,
        cached: cached_cost,
        audio: audio_cost
      }
    end

    def calculate_completion_costs(usage, pricing)
      details = usage["completion_tokens_details"] || {}

      reasoning_tokens = details["reasoning_tokens"] || 0
      audio_tokens = details["audio_tokens"] || 0
      accepted_prediction_tokens = details["accepted_prediction_tokens"] || 0
      rejected_prediction_tokens = details["rejected_prediction_tokens"] || 0
      regular_tokens = usage["completion_tokens"] - audio_tokens

      reasoning_cost = reasoning_tokens * pricing[:output]
      audio_cost = audio_tokens * pricing[:audio_output]
      accepted_prediction_cost = accepted_prediction_tokens * pricing[:output]
      rejected_prediction_cost = rejected_prediction_tokens * pricing[:output]
      regular_cost = regular_tokens * pricing[:output]

      {
        total: regular_cost + audio_cost,
        reasoning: reasoning_cost,
        audio: audio_cost,
        accepted_prediction: accepted_prediction_cost,
        rejected_prediction: rejected_prediction_cost
      }
    end
  end
end
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/MethodLength
