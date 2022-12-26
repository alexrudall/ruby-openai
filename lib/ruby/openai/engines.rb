module OpenAI
  class Engines
    include HTTParty
    base_uri "https://api.openai.com"

    def initialize(access_token: nil, organization_id: nil)
      Ruby::OpenAI.configuration.access_token = access_token if access_token
      Ruby::OpenAI.configuration.organization_id = organization_id if organization_id
    end

    def list(version: default_version)
      self.class.get(
        "/#{version}/engines",
        headers: Ruby::OpenAI.headers
      )
    end

    def retrieve(id:, version: default_version)
      self.class.get(
        "/#{version}/engines/#{id}",
        headers: Ruby::OpenAI.headers
      )
    end

    private

    def default_version
      "v1".freeze
    end
  end
end
