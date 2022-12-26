module OpenAI
  class Finetunes
    def initialize(access_token: nil, organization_id: nil)
      Ruby::OpenAI.configuration.access_token = access_token if access_token
      Ruby::OpenAI.configuration.organization_id = organization_id if organization_id
    end

    def list
      OpenAI::Client.get(path: "/fine-tunes")
    end

    def create(parameters: {})
      OpenAI::Client.post(path: "/fine-tunes", parameters: parameters.to_json)
    end

    def retrieve(id:)
      OpenAI::Client.get(path: "/fine-tunes/#{id}")
    end

    def cancel(id:)
      OpenAI::Client.post(path: "/fine-tunes/#{id}/cancel")
    end

    def events(id:)
      OpenAI::Client.get(path: "/fine-tunes/#{id}/events")
    end
  end
end
