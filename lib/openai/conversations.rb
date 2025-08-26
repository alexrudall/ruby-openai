module OpenAI
  class Conversations
    def initialize(client:)
      @client = client
    end

    def list(parameters: {})
      @client.get(path: "/conversations", parameters: parameters)
    end

    def retrieve(id:)
      @client.get(path: "/conversations/#{id}")
    end

    def create(parameters: {})
      @client.json_post(path: "/conversations", parameters: parameters)
    end

    def modify(id:, parameters: {})
      @client.json_post(path: "/conversations/#{id}", parameters: parameters)
    end

    def delete(id:)
      @client.delete(path: "/conversations/#{id}")
    end

    # Message operations within a conversation
    def messages(conversation_id:, parameters: {})
      @client.get(path: "/conversations/#{conversation_id}/messages", parameters: parameters)
    end

    def retrieve_message(conversation_id:, message_id:)
      @client.get(path: "/conversations/#{conversation_id}/messages/#{message_id}")
    end

    def create_message(conversation_id:, parameters: {})
      @client.json_post(path: "/conversations/#{conversation_id}/messages", parameters: parameters)
    end

    def delete_message(conversation_id:, message_id:)
      @client.delete(path: "/conversations/#{conversation_id}/messages/#{message_id}")
    end
  end
end
