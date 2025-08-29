require "mime/types"

module OpenAI
  module MimeTypes
    REGISTER_MIME_TYPES = { "jsonl" => "application/json" }.freeze

    def self.register
      REGISTER_MIME_TYPES.each do |register_type, mime_type|
        next if MIME::Types.of(register_type).any?

        MIME::Types[mime_type].first.add_extensions(register_type)
      end
    end
  end
end

OpenAI::MimeTypes.register
