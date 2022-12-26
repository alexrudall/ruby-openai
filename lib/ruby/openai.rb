require "httparty"
require "ruby/openai/client"
require "ruby/openai/engines"
require "ruby/openai/files"
require "ruby/openai/finetunes"
require "ruby/openai/images"
require "ruby/openai/models"
require "ruby/openai/version"

module Ruby
  module OpenAI
    class Error < StandardError; end
    class ConfigurationError < Error; end

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
end
