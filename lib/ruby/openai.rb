require_relative "../openai"

module Ruby
  module OpenAI
    def self.configuration
      warn "Ruby::OpenAI.configuration is deprecated, use OpenAI.configuration instead"
      ::OpenAI::Configuration.configuration
    end

    def self.configure
      warn "Ruby::OpenAI.configure is deprecated, use OpenAI.configure instead"
      ::OpenAI::Configuration.configure
    end
  end
end
