require "httparty"
require "ruby/openai/files"
require "ruby/openai/finetunes"
require "ruby/openai/models"
require "ruby/openai/client"
require "ruby/openai/version"
require "dotenv/load"

module Ruby
  module OpenAI
    class Error < StandardError; end
  end
end
