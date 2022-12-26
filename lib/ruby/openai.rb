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

    class Configuration
      attr_accessor :access_token, :organization_id

      def initialize
        @access_id = nil
        @organization_id = nil
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

    def self.headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{configuration.access_token}",
        "OpenAI-Organization" => configuration.organization_id
      }
    end

    def self.api_version
      "v1".freeze
    end
  end
end
