module OpenAI
  class Client
    include HTTParty
    base_uri "https://api.openai.com"

    def initialize(access_token: nil)
      @access_token = access_token || ENV["OPENAI_ACCESS_TOKEN"]
    end

    def call(engine:, prompt:, max_tokens:, version: "v1")
      self.class.post(
        "/#{version}/engines/#{engine}/completions",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}"
        },
        body: {
          prompt: prompt, max_tokens: max_tokens
        }.to_json
      )
    end
  end
end
