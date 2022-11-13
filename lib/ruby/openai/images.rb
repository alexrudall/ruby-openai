module OpenAI
  class Images
    include HTTParty
    base_uri "https://api.openai.com"

    def initialize(access_token: nil)
      @access_token = access_token || ENV.fetch("OPENAI_ACCESS_TOKEN")
    end

    def generate(version: default_version, parameters: {})
      self.class.post(
        "/#{version}/images/generations",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}"
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
