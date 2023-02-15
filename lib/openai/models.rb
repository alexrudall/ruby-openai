module OpenAI
  class Models
    def initialize(access_token: nil, organization_id: nil)
      OpenAI.configuration.access_token = access_token if access_token
      OpenAI.configuration.organization_id = organization_id if organization_id
    end

    def list
      OpenAI::Client.get(path: "/models")
    end

    def retrieve(id:)
      OpenAI::Client.get(path: "/models/#{id}")
    end
  end
end
