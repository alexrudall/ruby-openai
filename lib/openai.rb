require "httparty"

require_relative "openai/configuration"
require_relative "openai/request"
require_relative "openai/api"
require_relative "openai/client"
require_relative "openai/version"

module OpenAI
  extend Configuration

  class Error < StandardError; end
  class ConfigurationError < Error; end

  def self.client(options = {})
    Client.new(options)
  end

  def self.method_missing(method, *args, &block)
    return super unless client.respond_to(method)

    client.send(method, *args, &block)
  end

  def self.respond_to_missing?(method)
    client.respond_to(method) || super
  end
end
