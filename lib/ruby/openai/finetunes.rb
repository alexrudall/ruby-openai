module OpenAI
  class Finetunes
    def initialize(access_token: nil, organization_id: nil)
      Ruby::OpenAI.configuration.access_token = access_token if access_token
      Ruby::OpenAI.configuration.organization_id = organization_id if organization_id
    end

    def list(version: Ruby::OpenAI.api_version)
      OpenAI::Client.get(path: "/#{version}/fine-tunes")
    end

    def create(version: Ruby::OpenAI.api_version, parameters: {})
      OpenAI::Client.post(path: "/#{version}/fine-tunes", parameters: parameters.to_json)
    end

    def retrieve(id:, version: Ruby::OpenAI.api_version)
      OpenAI::Client.get(path: "/#{version}/fine-tunes/#{id}")
    end

    def cancel(id:, version: Ruby::OpenAI.api_version)
      OpenAI::Client.post(path: "/#{version}/fine-tunes/#{id}/cancel")
    end

    def events(id:, version: Ruby::OpenAI.api_version)
      OpenAI::Client.get(path: "/#{version}/fine-tunes/#{id}/events")
    end
  end
end
