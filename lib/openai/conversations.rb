module OpenAI
  class Conversations
    def initialize(client:)
      @client = client
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

    # Item operations within a conversation
    def create_items(conversation_id:, parameters: {})
      @client.json_post(path: "/conversations/#{conversation_id}/items", parameters: parameters)
    end

    def list_items(conversation_id:, parameters: {})
      @client.get(path: "/conversations/#{conversation_id}/items", parameters: parameters)
    end

    def get_item(conversation_id:, item_id:)
      @client.get(path: "/conversations/#{conversation_id}/items/#{item_id}")
    end

    def delete_item(conversation_id:, item_id:)
      @client.delete(path: "/conversations/#{conversation_id}/items/#{item_id}")
    end
  end
end
