module OpenAI
  class Models
    def initialize(access_token: nil, organization_id: nil)
      Ruby::OpenAI.configuration.access_token = access_token if access_token
      Ruby::OpenAI.configuration.organization_id = organization_id if organization_id
    end

    def list(version: Ruby::OpenAI.api_version)
      OpenAI::Client.get(path: "/#{version}/models")
    end

    def retrieve(id:, version: Ruby::OpenAI.api_version)
      OpenAI::Client.get(path: "/#{version}/models/#{id}")
    end
  end
end
