require "httparty"
require "ruby/openai/engines"
require "ruby/openai/files"
require "ruby/openai/finetunes"
require "ruby/openai/client"
require "ruby/openai/version"
require "dotenv/load"

module Ruby
  module OpenAI
    class Error < StandardError; end
  end
end
