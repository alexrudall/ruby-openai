module OpenAI
  class Client
    include OpenAI::HTTP

    attr_reader :access_token, :organization_id, :uri_base, :request_timeout, :extra_headers

    def initialize(access_token: nil, organization_id: nil, uri_base: nil,
                   request_timeout: nil, extra_headers: {})
      @access_token = access_token || OpenAI.configuration.access_token
      @organization_id = organization_id || OpenAI.configuration.organization_id
      @uri_base = uri_base || OpenAI.configuration.uri_base
      @request_timeout = request_timeout || OpenAI.configuration.request_timeout
      @extra_headers = extra_headers
    end

    def chat(parameters: {})
      json_post(path: "/chat/completions", parameters: parameters)
    end

    def completions(parameters: {})
      json_post(path: "/completions", parameters: parameters)
    end

    def edits(parameters: {})
      json_post(path: "/edits", parameters: parameters)
    end

    def embeddings(parameters: {})
      json_post(path: "/embeddings", parameters: parameters)
    end

    def files
      @files ||= OpenAI::Files.new(client: self)
    end

    def finetunes
      @finetunes ||= OpenAI::Finetunes.new(client: self)
    end

    def images
      @images ||= OpenAI::Images.new(client: self)
    end

    def models
      @models ||= OpenAI::Models.new(client: self)
    end

    def moderations(parameters: {})
      json_post(path: "/moderations", parameters: parameters)
    end

    def transcribe(parameters: {})
      multipart_post(path: "/audio/transcriptions", parameters: parameters)
    end

    def translate(parameters: {})
      multipart_post(path: "/audio/translations", parameters: parameters)
    end
  end
end
