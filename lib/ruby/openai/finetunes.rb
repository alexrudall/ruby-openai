module OpenAI
  class Finetunes
    include HTTParty
    base_uri "https://api.openai.com"

    def initialize(access_token: nil)
      @access_token = access_token || ENV["OPENAI_ACCESS_TOKEN"]
    end

    def list(version: default_version)
      self.class.get(
        "/#{version}/fine-tunes",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}"
        }
      )
    end

    def create(version: default_version, parameters: {})
      self.class.post(
        "/#{version}/fine-tunes",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}"
        },
        body: parameters.to_json
      )
    end

    def retrieve(id:, version: default_version)
      self.class.get(
        "/#{version}/fine-tunes/#{id}",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}"
        }
      )
    end

    def cancel(id:, version: default_version)
      self.class.post(
        "/#{version}/fine-tunes/#{id}/cancel",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}"
        }
      )
    end

    def events(id:, version: default_version)
      self.class.get(
        "/#{version}/fine-tunes/#{id}/events",
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
