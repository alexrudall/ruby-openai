module OpenAI
  class Client
    include HTTParty
    base_uri "https://api.openai.com/v1/engines"

    def initialize(access_token: nil)
      @access_token = access_token || ENV["OPENAI_ACCESS_TOKEN"]
    end

    def call(engine:, prompt:, max_tokens:)
      self.class.post(
        "/#{engine}/completions",
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
