module OpenAI
  class Error < StandardError; end
  class ConfigurationError < Error; end

  class MissingAccessTokenError < ConfigurationError
    def message
      "OpenAI access token missing! See https://github.com/alexrudall/ruby-openai#usage"
    end
  end

  class MissingRequiredParameterError < OpenAI::Error
    def initialize(parameter_name)
      super
      @parameter_name = parameter_name
    end

    def message
      "The parameter #{@parameter_name} is required."
    end
  end
end
