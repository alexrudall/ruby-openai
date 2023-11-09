module OpenAI
  class Messages
    def initialize(client:)
      @client = client.beta(assistants: "v1")
    end

    def list(thread_id:)
      @client.get(path: "/threads/#{thread_id}/messages")
    end

    def retrieve(thread_id:, id:)
      @client.get(path: "/threads/#{thread_id}/messages/#{id}")
    end

    def create(thread_id:, parameters: {})
      @client.json_post(path: "/threads/#{thread_id}/messages", parameters: parameters)
    end

    def modify(id:, thread_id:, parameters: {})
      @client.json_post(path: "/threads/#{thread_id}/messages/#{id}", parameters: parameters)
    end
  end
end
