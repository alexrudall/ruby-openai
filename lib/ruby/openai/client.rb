module OpenAI
  class Client
    def initialize(access_token: nil)
      @access_token = access_token || ENV["OPENAI_ACCESS_TOKEN"]
    end

    def call(prompt:); end
  end
end
