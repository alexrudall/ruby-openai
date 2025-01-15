module OpenAI
  class Pricing
    COSTS = {
      "gpt-4o" => {input: 2.5, cached_input: 1.25, output: 10.0, audio_input: nil, audio_output: nil},
      "gpt-4o-2024-11-20" => {input: 2.5, cached_input: 1.25, output: 10.0, audio_input: nil, audio_output: nil},
      "gpt-4o-2024-08-06" => {input: 2.5, cached_input: 1.25, output: 10.0, audio_input: nil, audio_output: nil},
      "gpt-4o-audio-preview" => {input: 2.5, cached_input: nil, output: 10.0, audio_input: 40.0, audio_output: 80.0},
      "gpt-4o-audio-preview-2024-12-17" => {input: 2.5, cached_input: nil, output: 10.0, audio_input: 40.0, audio_output: 80.0},
      "gpt-4o-audio-preview-2024-10-01" => {input: 2.5, cached_input: nil, output: 10.0, audio_input: 100.0, audio_output: 200.0},
      "gpt-4o-2024-05-13" => {input: 5.0, cached_input: 2.5, output: 15.0, audio_input: nil, audio_output: nil},
      "gpt-4o-mini" => {input: 0.15, cached_input: 0.075, output: 0.6, audio_input: nil, audio_output: nil},
      "gpt-4o-mini-2024-07-18" => {input: 0.15, cached_input: 0.075, output: 0.6, audio_input: nil, audio_output: nil},
      "gpt-4o-mini-audio-preview" => {input: 0.15, cached_input: nil, output: 0.6, audio_input: 10.0, audio_output: 20.0},
      "gpt-4o-mini-audio-preview-2024-12-17" => {input: 0.15, cached_input: nil, output: 0.6, audio_input: 10.0, audio_output: 20.0},
      "o1" => {input: 15.0, cached_input: 7.5, output: 60.0, audio_input: nil, audio_output: nil},
      "o1-2024-12-17" => {input: 15.0, cached_input: 7.5, output: 60.0, audio_input: nil, audio_output: nil},
      "o1-preview" => {input: 15.0, cached_input: 7.5, output: 60.0, audio_input: nil, audio_output: nil},
      "o1-preview-2024-09-12" => {input: 15.0, cached_input: 7.5, output: 60.0, audio_input: nil, audio_output: nil},
      "o1-mini" => {input: 3.0, cached_input: 1.5, output: 12.0, audio_input: nil, audio_output: nil},
      "o1-mini-2024-09-12" => {input: 3.0, cached_input: 1.5, output: 12.0, audio_input: nil, audio_output: nil},
      "text-embedding-3-small" => {input: 0.02, cached_input: 0.01, output: nil, audio_input: nil, audio_output: nil},
      "text-embedding-3-large" => {input: 0.13, cached_input: 0.065, output: nil, audio_input: nil, audio_output: nil},
      "ada v2" => {input: 0.1, cached_input: 0.05, output: nil, audio_input: nil, audio_output: nil}
    }
    

    def self.calculate(response)
      new.calculate(response)
    end

    def calculate(response, costs = COSTS)
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
