require "httparty"

require_relative "openai/client"
require_relative "openai/files"
require_relative "openai/finetunes"
require_relative "openai/images"
require_relative "openai/models"
require_relative "openai/version"

module OpenAI
  class Error < StandardError; end
  class ConfigurationError < Error; end

  class Configuration
    attr_writer :access_token
    attr_accessor :api_version, :organization_id, :request_timeout

    DEFAULT_API_VERSION = "v1".freeze
    DEFAULT_REQUEST_TIMEOUT = 60

    def initialize
      @access_token = nil
      @api_version = DEFAULT_API_VERSION
      @organization_id = nil
      @request_timeout = DEFAULT_REQUEST_TIMEOUT
    end

    def access_token
      return @access_token if @access_token

      error_text = "OpenAI access token missing! See https://github.com/alexrudall/ruby-openai#usage"
      raise ConfigurationError, error_text
    end
  end

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= OpenAI::Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
