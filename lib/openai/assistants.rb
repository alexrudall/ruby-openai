module OpenAI
  class Assistants
    def initialize(client:)
      @client = client.beta
    end

    def list
      @client.get(path: "/assistants")
    end

    def retrieve(id:)
      @client.get(path: "/assistants/#{id}")
    end
  end
end
