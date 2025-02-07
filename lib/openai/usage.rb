module OpenAI
  class Usage
    def initialize(client:)
      @client = client
    end

    def completions(parameters: {})
      @client.admin.get(
        path: "/organization/usage/completions",
        parameters: parameters
      )
    end

    def embeddings(parameters: {})
      @client.admin.get(
        path: "/organization/usage/embeddings",
        parameters: parameters
      )
    end

    def moderations(parameters: {})
      @client.admin.get(
        path: "/organization/usage/moderations",
        parameters: parameters
      )
    end

    def images(parameters: {})
      @client.admin.get(
        path: "/organization/usage/images",
        parameters: parameters
      )
    end

    def audio_speeches(parameters: {})
      @client.admin.get(
        path: "/organization/usage/audio_speeches",
        parameters: parameters
      )
    end

    def audio_transcriptions(parameters: {})
      @client.admin.get(
        path: "/organization/usage/audio_transcriptions",
        parameters: parameters
      )
    end

    def vector_stores(parameters: {})
      @client.admin.get(
        path: "/organization/usage/vector_stores",
        parameters: parameters
      )
    end

    def code_interpreter_sessions(parameters: {})
      @client.admin.get(
        path: "/organization/usage/code_interpreter_sessions",
        parameters: parameters
      )
    end

    def costs(parameters: {})
      @client.admin.get(
        path: "/organization/costs",
        parameters: parameters
      )
    end
  end
end
