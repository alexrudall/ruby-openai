require "httparty"

require_relative "openai/configuration"
require_relative "openai/files"
require_relative "openai/finetunes"
require_relative "openai/images"
require_relative "openai/models"
require_relative "openai/version"
require_relative "openai/client"

module OpenAI
  extend Configuration

  class Error < StandardError; end
  class ConfigurationError < Error; end
end
