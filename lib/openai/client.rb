module OpenAI
  class Client
    Dir[File.expand_path("../client/*.rb", __FILE__)].each { |f| require f }

    include Audio
    include Edits
    include Files
    include Finetunes
    include Images
    include Models
    include Moderations
    include Completions

    URI_BASE = "https://api.openai.com/".freeze
    attr_accessor(*Configuration::VALID_OPTIONS_KEYS)

    def initialize(options={})
      options = OpenAI.options.merge(options)
      Configuration::VALID_OPTIONS_KEYS.each do |key|
        send("#{key}=", options[key])
      end
    end

    def self.get(path:)
      HTTParty.get(
        uri(path: path),
        headers: headers
      )
    end

    def self.json_post(path:, parameters:)
      HTTParty.post(
        uri(path: path),
        headers: headers,
        body: parameters&.to_json
      )
    end

    def self.multipart_post(path:, parameters: nil)
      HTTParty.post(
        uri(path: path),
        headers: headers.merge({ "Content-Type" => "multipart/form-data" }),
        body: parameters
      )
    end

    def self.delete(path:)
      HTTParty.delete(
        uri(path: path),
        headers: headers
      )
    end

    private_class_method def self.uri(path:)
      URI_BASE + OpenAI.api_version + path
    end

    private_class_method def self.headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{OpenAI.access_token}",
        "OpenAI-Organization" => OpenAI.organization_id
      }
    end
  end
end
