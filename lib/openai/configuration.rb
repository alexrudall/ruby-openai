module OpenAI
  class Configuration
    attr_writer :access_token
    attr_accessor :api_version, :organization_id

    DEFAULT_API_VERSION = "v1".freeze

    def initialize
      @access_token = nil
      @api_version = DEFAULT_API_VERSION
      @organization_id = nil
    end

    def access_token
      return @access_token if @access_token
    end
  end
end
