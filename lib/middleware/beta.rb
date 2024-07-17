# frozen_string_literal: true

module OpenAI
  class BetaMiddleware < Faraday::Middleware
    BETA_REGEX = %r{
      \A/#{OpenAI.configuration.api_version}
      /(assistants|batches|threads|vector_stores)
    }ix.freeze

    def on_request(env)
      return unless env[:url].path.match?(BETA_REGEX)

      env[:request_headers].merge!(
        {
          "OpenAI-Beta" => "assistants=v2"
        }
      )
    end
  end
end
