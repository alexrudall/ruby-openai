require_relative "openai/version"
require_relative "openai/configuration"
require_relative "openai/error"
require_relative "openai/client"

module OpenAI
  def self.configuration
    @configuration ||= OpenAI::Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
