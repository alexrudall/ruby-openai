module OpenAI
  class Models
    def initialize(client: nil, access_token: nil, organization_id: OpenAI::Client::NULL_ORGANIZATION_ID)
      @client = if client.nil?
        OpenAI::Client.new(access_token: access_token, organization_id: organization_id)
      else
        client
      end
    end

    def list
      @client.get(path: "/models")
    end

    def retrieve(id:)
      @client.get(path: "/models/#{id}")
    end
  end
end
