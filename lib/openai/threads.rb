module OpenAI
  class Threads
    def initialize(client:)
      @client = client.beta(assistants: "v1")
    end

    def list
      @client.get(path: "/threads")
    end

    def retrieve(id:)
      @client.get(path: "/threads/#{id}")
    end

    def create(parameters: {})
      @client.json_post(path: "/threads", parameters: parameters)
    end

    def delete(id:)
      @client.delete(path: "/threads/#{id}")
    end
  end
end
