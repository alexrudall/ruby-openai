module OpenAI
  class Configuration
    attr_accessor :access_token, :api_version, :organization_id

    DEFAULT_API_VERSION = "v1".freeze

    def initialize
      reset
    end

    def reset
      @access_token = nil
      @api_version = DEFAULT_API_VERSION
      @organization_id = nil
    end
  end
end
