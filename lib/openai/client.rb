module OpenAI
  class Client
    URI_BASE = "https://api.openai.com/".freeze
    attr_accessor(*Configuration::VALID_OPTIONS_KEYS)

    def initialize(options={})
      options = OpenAI.options.merge(options)
      Configuration::VALID_OPTIONS_KEYS.each do |key|
        send("#{key}=", options[key])
      end
    end

    def chat(parameters: {})
      OpenAI::Client.json_post(path: "/chat/completions", parameters: parameters)
    end

    def completions(parameters: {})
      OpenAI::Client.json_post(path: "/completions", parameters: parameters)
    end

    def edits(parameters: {})
      OpenAI::Client.json_post(path: "/edits", parameters: parameters)
    end

    def embeddings(parameters: {})
      OpenAI::Client.json_post(path: "/embeddings", parameters: parameters)
    end

    def files
      @files ||= OpenAI::Files
    end

    def finetunes
      @finetunes ||= OpenAI::Finetunes
    end

    def images
      @images ||= OpenAI::Images
    end

    def models
      @models ||= OpenAI::Models
    end

    def moderations(parameters: {})
      OpenAI::Client.json_post(path: "/moderations", parameters: parameters)
    end

    def transcribe(parameters: {})
      OpenAI::Client.multipart_post(path: "/audio/transcriptions", parameters: parameters)
    end

    def translate(parameters: {})
      OpenAI::Client.multipart_post(path: "/audio/translations", parameters: parameters)
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
