module OpenAI
  class Engines
    include HTTParty
    base_uri "https://api.openai.com"

    def initialize(access_token: nil)
      @access_token = access_token || ENV.fetch("OPENAI_ACCESS_TOKEN")
    end

    def list(version: default_version)
      self.class.get(
        "/#{version}/engines",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}"
        }
      )
    end

    def retrieve(id:, version: default_version)
      self.class.get(
        "/#{version}/engines/#{id}",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}"
        }
      )
    end

    private

    def default_version
      "v1".freeze
    end
  end
end
