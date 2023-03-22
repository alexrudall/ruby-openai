module OpenAI
  class Client
    URI_BASE = "https://api.openai.com/".freeze

    def initialize(access_token: nil, organization_id: nil, request_timeout: nil)
      OpenAI.configuration.access_token = access_token if access_token
      OpenAI.configuration.organization_id = organization_id if organization_id
      OpenAI.configuration.request_timeout = request_timeout if request_timeout
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
      @files ||= OpenAI::Files.new
    end

    def finetunes
      @finetunes ||= OpenAI::Finetunes.new
    end

    def images
      @images ||= OpenAI::Images.new
    end

    def models
      @models ||= OpenAI::Models.new
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
        headers: headers,
        timeout: request_timeout
      )
    end

    def self.json_post(path:, parameters:)
      HTTParty.post(
        uri(path: path),
        headers: headers,
        body: parameters&.to_json,
        timeout: request_timeout
      )
    end

    def self.multipart_post(path:, parameters: nil)
      HTTParty.post(
        uri(path: path),
        headers: headers.merge({ "Content-Type" => "multipart/form-data" }),
        body: parameters,
        timeout: request_timeout
      )
    end

    def self.delete(path:)
      HTTParty.delete(
        uri(path: path),
        headers: headers,
        timeout: request_timeout
      )
    end

    private_class_method def self.uri(path:)
      URI_BASE + OpenAI.configuration.api_version + path
    end

    private_class_method def self.headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{OpenAI.configuration.access_token}",
        "OpenAI-Organization" => OpenAI.configuration.organization_id
      }
    end

    private_class_method def self.request_timeout
      OpenAI.configuration.request_timeout
    end
  end
end
