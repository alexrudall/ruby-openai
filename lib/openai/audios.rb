module OpenAI
  class Audios
    def initialize(access_token: nil, organization_id: nil)
      OpenAI.configuration.access_token = access_token if access_token
      OpenAI.configuration.organization_id = organization_id if organization_id
    end

    def transcribe(parameters: {})
      OpenAI::Client.multipart_post(path: "/audio/transcriptions", parameters: parameters)
    end

    def translate(parameters: {})
      OpenAI::Client.multipart_post(path: "/audio/translations", parameters: parameters)
    end
  end
end
