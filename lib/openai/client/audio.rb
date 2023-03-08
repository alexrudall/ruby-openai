module OpenAI
  module Audio
    def transcribe(parameters: {})
      multipart_post("/audio/transcriptions", parameters: parameters)
    end

    def translate(parameters: {})
      multipart_post("/audio/translations", parameters: parameters)
    end
  end
end
