module OpenAI
  class Finetunes
    def initialize(client: nil, access_token: nil,
                   organization_id: OpenAI::Client::NULL_ORGANIZATION_ID)
      @client = if client.nil?
                  OpenAI::Client.new(access_token: access_token,
                                     organization_id: organization_id)
                else
                  client
                end
    end

    def list
      @client.get(path: "/fine-tunes")
    end

    def create(parameters: {})
      @client.post(path: "/fine-tunes", parameters: parameters)
    end

    def retrieve(id:)
      @client.get(path: "/fine-tunes/#{id}")
    end

    def cancel(id:)
      @client.post(path: "/fine-tunes/#{id}/cancel")
    end

    def events(id:)
      @client.get(path: "/fine-tunes/#{id}/events")
    end
  end
end
