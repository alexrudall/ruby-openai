module OpenAI
  class Client
    URI_BASE = "https://api.openai.com/".freeze

    NULL_ORGANIZATION_ID = Object.new.freeze

    attr_reader :access_token, :organization_id, :api_version

    def initialize(access_token: nil, organization_id: NULL_ORGANIZATION_ID, api_version: nil)
      @access_token = access_token || Ruby::OpenAI.configuration.access_token
      @organization_id = if organization_id == NULL_ORGANIZATION_ID
                           Ruby::OpenAI.configuration.access_token
                         else
                           organization_id
                         end
      @api_version = api_version || Ruby::OpenAI.configuration.api_version
    end

    def completions(parameters: {})
      json_post(path: "/completions", parameters: parameters)
    end

    def edits(parameters: {})
      json_post(path: "/edits", parameters: parameters)
    end

    def embeddings(parameters: {})
      json_post(path: "/embeddings", parameters: parameters)
    end

    def files
      @files ||= OpenAI::Files.new(client: self)
    end

    def finetunes
      @finetunes ||= OpenAI::Finetunes.new(client: self)
    end

    def images
      @images ||= OpenAI::Images.new(client: self)
    end

    def models
      @models ||= OpenAI::Models.new(client: self)
    end

    def moderations(parameters: {})
      json_post(path: "/moderations", parameters: parameters)
    end

    def get(path:)
      HTTParty.get(
        uri(path: path),
        headers: headers
      )
    end

    def json_post(path:, parameters: nil)
      HTTParty.post(
        uri(path: path),
        headers: headers,
        body: parameters&.to_json
      )
    end

    def multipart_post(path:, parameters: nil)
      HTTParty.post(
        uri(path: path),
        headers: headers.merge({ "Content-Type" => "multipart/form-data" }),
        body: parameters
      )
    end

    def delete(path:)
      HTTParty.delete(
        uri(path: path),
        headers: headers
      )
    end

    private

    def uri(path:)
      URI_BASE + api_version + path
    end

    def headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{access_token}",
        "OpenAI-Organization" => organization_id
      }
    end
  end
end
