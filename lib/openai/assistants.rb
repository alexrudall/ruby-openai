module OpenAI
  class Assistants
    def initialize(client:)
      @client = client.beta(assistants: "v2")
    end

    def list
      @client.get(path: "/assistants")
    end

    def retrieve(id:)
      @client.get(path: "/assistants/#{id}")
    end

    def create(parameters: {})
      @client.json_post(path: "/assistants", parameters: parameters)
    end

    def modify(id:, parameters: {})
      @client.json_post(path: "/assistants/#{id}", parameters: parameters)
    end

    def delete(id:)
      @client.delete(path: "/assistants/#{id}")
    end
  end
end
