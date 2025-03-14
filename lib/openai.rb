require "faraday"
require "faraday/multipart" if Gem::Version.new(Faraday::VERSION) >= Gem::Version.new("2.0")
require_relative "openai/http"
require_relative "openai/client"
require_relative "openai/files"
require_relative "openai/finetunes"
require_relative "openai/images"
require_relative "openai/models"
require_relative "openai/responses"
require_relative "openai/assistants"
require_relative "openai/threads"
require_relative "openai/messages"
require_relative "openai/runs"
require_relative "openai/run_steps"
require_relative "openai/vector_stores"
require_relative "openai/vector_store_files"
require_relative "openai/vector_store_file_batches"
require_relative "openai/audio"
require_relative "openai/version"
require_relative "openai/batches"
require_relative "openai/usage"

module OpenAI
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class AuthenticationError < Error; end

  class MiddlewareErrors < Faraday::Middleware
    def call(env)
      @app.call(env)
    rescue Faraday::Error => e
      raise e unless e.response.is_a?(Hash)

      OpenAI.log_message("OpenAI HTTP Error", e.response[:body], :error)
      raise e
    end
  end

  class Configuration
    attr_accessor :access_token,
                  :admin_token,
                  :api_type,
                  :api_version,
                  :log_errors,
                  :organization_id,
                  :uri_base,
                  :request_timeout,
                  :extra_headers

    DEFAULT_API_VERSION = "v1".freeze
    DEFAULT_URI_BASE = "https://api.openai.com/".freeze
    DEFAULT_REQUEST_TIMEOUT = 120
    DEFAULT_LOG_ERRORS = false

    def initialize
      @access_token = nil
      @admin_token = nil
      @api_type = nil
      @api_version = DEFAULT_API_VERSION
      @log_errors = DEFAULT_LOG_ERRORS
      @organization_id = nil
      @uri_base = DEFAULT_URI_BASE
      @request_timeout = DEFAULT_REQUEST_TIMEOUT
      @extra_headers = {}
    end
  end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= OpenAI::Configuration.new
    end

    def configure
      yield(configuration)
    end

    # Estimate the number of tokens in a string, using the rules of thumb from OpenAI:
    # https://help.openai.com/en/articles/4936856-what-are-tokens-and-how-to-count-them
    def rough_token_count(content = "")
      raise ArgumentError, "rough_token_count requires a string" unless content.is_a? String
      return 0 if content.empty?

      count_by_chars = content.size / 4.0
      count_by_words = content.split.size * 4.0 / 3
      estimate = ((count_by_chars + count_by_words) / 2.0).round
      [1, estimate].max
    end

    # Log a message with appropriate formatting
    # @param prefix [String] Prefix to add to the message
    # @param message [String] The message to log
    # @param level [Symbol] The log level (:error, :warn, etc.)
    def log_message(prefix, message, level = :warn)
      color = level == :error ? "\033[31m" : "\033[33m"
      logger = Logger.new($stdout)
      logger.formatter = proc do |_severity, _datetime, _progname, msg|
        "#{color}#{prefix} (spotted in ruby-openai #{VERSION}): #{msg}\n\033[0m"
      end
      logger.send(level, message)
    end
  end
end
