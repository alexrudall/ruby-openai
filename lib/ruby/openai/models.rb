module OpenAI
  class Models
    include HTTParty
    base_uri "https://api.openai.com"

    def initialize(access_token: nil, organization_id: nil)
      Ruby::OpenAI.configuration.access_token = access_token if access_token
      Ruby::OpenAI.configuration.organization_id = organization_id if organization_id
    end

    def list(version: Ruby::OpenAI.api_version)
      self.class.get(
        "/#{version}/models",
        headers: Ruby::OpenAI.headers
      )
    end

    def retrieve(id:, version: Ruby::OpenAI.api_version)
      self.class.get(
        "/#{version}/models/#{id}",
        headers: Ruby::OpenAI.headers
      )
    end
  end
end
