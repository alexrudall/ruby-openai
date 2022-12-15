module OpenAI
  class Finetunes
    include HTTParty
    base_uri "https://api.openai.com"

    def initialize(access_token: nil, organization_id: nil)
      @access_token = access_token || ENV.fetch("OPENAI_ACCESS_TOKEN")
      @organization_id = organization_id || ENV.fetch("OPENAI_ORGANIZATION_ID")
    end

    def list(version: default_version)
      self.class.get(
        "/#{version}/fine-tunes",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}",
          "OpenAI-Organization" => @organization_id
        }
      )
    end

    def create(version: default_version, parameters: {})
      self.class.post(
        "/#{version}/fine-tunes",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}",
          "OpenAI-Organization" => @organization_id
        },
        body: parameters.to_json
      )
    end

    def retrieve(id:, version: default_version)
      self.class.get(
        "/#{version}/fine-tunes/#{id}",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}",
          "OpenAI-Organization" => @organization_id
        }
      )
    end

    def cancel(id:, version: default_version)
      self.class.post(
        "/#{version}/fine-tunes/#{id}/cancel",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}",
          "OpenAI-Organization" => @organization_id
        }
      )
    end

    def events(id:, version: default_version)
      self.class.get(
        "/#{version}/fine-tunes/#{id}/events",
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
