module OpenAI
  class Client
    URI_BASE = "https://api.openai.com/".freeze

    def initialize(access_token: nil, organization_id: nil)
      Ruby::OpenAI.configuration.access_token = access_token if access_token
      Ruby::OpenAI.configuration.organization_id = organization_id if organization_id
    end

    def completions(parameters: {})
      OpenAI::Client.post(path: "/completions", parameters: parameters)
    end

    def edits(parameters: {})
      OpenAI::Client.post(path: "/edits", parameters: parameters)
    end

    def embeddings(parameters: {})
      OpenAI::Client.post(path: "/embeddings", parameters: parameters)
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
      OpenAI::Client.post(path: "/moderations", parameters: parameters)
    end

    def self.get(path:)
      HTTParty.get(
        uri(path: path),
        headers: headers
      )
    end

    def self.post(path:, parameters: nil)
      HTTParty.post(
        uri(path: path),
        headers: headers,
        body: parameters.to_json
      )
    end

    def self.delete(path:)
      HTTParty.delete(
        uri(path: path),
        headers: headers
      )
    end

    private_class_method def self.uri(path:)
      URI_BASE + Ruby::OpenAI.configuration.api_version + path
    end

    private_class_method def self.headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{Ruby::OpenAI.configuration.access_token}",
        "OpenAI-Organization" => Ruby::OpenAI.configuration.organization_id
      }
    end
  end
end
