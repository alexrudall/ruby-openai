module OpenAI
  class Error < StandardError; end
  class ConfigurationError < Error; end

  class MissingAccessTokenError < ConfigurationError
    def message
      "OpenAI access token missing! See https://github.com/alexrudall/ruby-openai#usage"
    end
  end
end
