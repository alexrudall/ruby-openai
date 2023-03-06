module OpenAI
  module Configuration
    VALID_OPTIONS_KEYS = [:access_token, :api_version, :organization_id]
    DEFAULT_API_VERSION = "v1".freeze

    attr_accessor(*VALID_OPTIONS_KEYS)

    def self.extended(base)
      base.reset
    end

    def configure
      yield self
    end

    def options
      VALID_OPTIONS_KEYS.inject({}) do |option, key|
        option.merge!(key => send(key))
      end
    end

    def reset
      self.access_token    = ENV.fetch("OPENAI_ACCESS_TOKEN")
      self.organization_id = ENV.fetch("OPENAI_ORGANIZATION_ID", nil)
      self.api_version     = DEFAULT_API_VERSION
    end
  end
end
