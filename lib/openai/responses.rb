module OpenAI
  class Responses
    def initialize(client:)
      @client = client
    end

    def create(parameters: {})
      @client.json_post(path: "/responses", parameters: parameters)
    end

    def retrieve(response_id:)
      @client.get(path: "/responses/#{response_id}")
    end

    def delete(response_id:)
      @client.delete(path: "/responses/#{response_id}")
    end

    def input_items(response_id:, parameters: {})
      @client.get(path: "/responses/#{response_id}/input_items", parameters: parameters)
    end
  end
end
