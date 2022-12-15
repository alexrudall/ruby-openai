module OpenAI
  class Models
    include HTTParty
    base_uri "https://api.openai.com"

    def initialize(access_token: nil, organization_id: nil)
      @access_token = access_token || ENV.fetch("OPENAI_ACCESS_TOKEN")
      @organization_id = organization_id || ENV.fetch("OPENAI_ORGANIZATION_ID")
    end

    def list(version: default_version)
      self.class.get(
        "/#{version}/models",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}",
          "OpenAI-Organization" => @organization_id
        }
      )
    end

    def retrieve(id:, version: default_version)
      self.class.get(
        "/#{version}/models/#{id}",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}",
          "OpenAI-Organization" => @organization_id
        }
      )
    end

    private

    def default_version
      "v1".freeze
    end
  end
end
