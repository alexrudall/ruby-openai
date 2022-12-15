module OpenAI
  class Images
    include HTTParty
    base_uri "https://api.openai.com"

    def initialize(access_token: nil, organization_id: nil)
      @access_token = access_token || ENV.fetch("OPENAI_ACCESS_TOKEN")
      @organization_id = organization_id || ENV.fetch("OPENAI_ORGANIZATION_ID", nil)
    end

    def generate(version: default_version, parameters: {})
      self.class.post(
        "/#{version}/images/generations",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}",
          "OpenAI-Organization" => @organization_id
        },
        body: parameters.to_json
      )
    end

    private

    def default_version
      "v1".freeze
    end
  end
end
