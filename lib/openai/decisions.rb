module OpenAI
  class Decisions
    def initialize(client:)
      @client = client
    end

    def create(parameters: {})
      @client.json_post(path: "/decisions", parameters: parameters)
    end
  end
end
