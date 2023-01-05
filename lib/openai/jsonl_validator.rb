require "json"

module OpenAI
  class JsonlValidator
    def self.validate(source:)
      source.each_line.with_index do |line, index|
        JSON.parse(line)
      rescue JSON::ParserError => e
        # TODO: This should probably be a gem specific error rather than a
        # JSON::ParserError
        raise JSON::ParserError, "#{e.message} - found on line #{index + 1}"
      end
      true
    end
  end
end
