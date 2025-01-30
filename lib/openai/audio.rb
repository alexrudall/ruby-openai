module OpenAI
  class Audio
    def initialize(client:)
      @client = client
    end

    def transcribe(parameters: {})
      plain_text_response = parameters[:response_format] == "vtt"
      @client.multipart_post(path: "/audio/transcriptions", parameters: parameters,
                             plain_text_response: plain_text_response)
    end

    def translate(parameters: {})
      @client.multipart_post(path: "/audio/translations", parameters: parameters)
    end

    def speech(parameters: {})
      @client.json_post(path: "/audio/speech", parameters: parameters)
    end
  end
end
