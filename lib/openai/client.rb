module OpenAI
  class Client
    def initialize(access_token: nil, organization_id: nil, uri_base: nil, request_timeout: nil)
      OpenAI.configuration.access_token = access_token if access_token
      OpenAI.configuration.organization_id = organization_id if organization_id
      OpenAI.configuration.uri_base = uri_base if uri_base
      OpenAI.configuration.request_timeout = request_timeout if request_timeout
    end

    def chat(parameters: {})
      OpenAI::Client.json_post(path: "/chat/completions", parameters: parameters)
    end

    def completions(parameters: {})
      OpenAI::Client.json_post(path: "/completions", parameters: parameters)
    end

    def edits(parameters: {})
      OpenAI::Client.json_post(path: "/edits", parameters: parameters)
    end

    def embeddings(parameters: {})
      OpenAI::Client.json_post(path: "/embeddings", parameters: parameters)
    end

    def files
      @files ||= OpenAI::Files.new
    end

    def finetunes
      @finetunes ||= OpenAI::Finetunes.new
    end

    def images
      @images ||= OpenAI::Images.new
    end

    def models
      @models ||= OpenAI::Models.new
    end

    def moderations(parameters: {})
      OpenAI::Client.json_post(path: "/moderations", parameters: parameters)
    end

    def transcribe(parameters: {})
      OpenAI::Client.multipart_post(path: "/audio/transcriptions", parameters: parameters)
    end

    def translate(parameters: {})
      OpenAI::Client.multipart_post(path: "/audio/translations", parameters: parameters)
    end

    def self.get(path:)
      conn.get(uri(path: path), timeout: OpenAI.configuration.request_timeout) do |req|
        req.headers = headers
      end
    end

    def self.json_post(path:, parameters:)
      conn.post(uri(path: path), timeout: OpenAI.configuration.request_timeout) do |req|
        req.headers = headers
        if parameters[:stream] && parameters[:on_data].is_a?(Proc)
          req.options.on_data = parameters[:on_data]
        end
        parameters.delete(:on_data)
        req.body = parameters.to_json
      end
    end

    def self.multipart_post(path:, parameters: nil)
      conn.post(uri(path: path), timeout: OpenAI.configuration.request_timeout) do |req|
        req.headers = headers.merge({ "Content-Type" => "multipart/form-data" })
        req.body = multipart_parameters(parameters)
      end
    end

    def self.delete(path:)
      conn.delete(uri(path: path), timeout: OpenAI.configuration.request_timeout) do |req|
        req.headers = headers
      end
    end

    private_class_method def self.conn
      Faraday.new do |f|
        f.request :multipart
      end
    end

    private_class_method def self.uri(path:)
      OpenAI.configuration.uri_base + OpenAI.configuration.api_version + path
    end

    private_class_method def self.headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{OpenAI.configuration.access_token}",
        "OpenAI-Organization" => OpenAI.configuration.organization_id
      }
    end

    private_class_method def self.request_timeout
      OpenAI.configuration.request_timeout
    end

    private_class_method def self.mime_type(file_path)
      return "application/jsonl" if file_path.end_with?(".jsonl")

      MIME::Types.type_for(file_path).first.content_type
    end

    private_class_method def self.multipart_parameters(parameters)
      return unless parameters

      parameters.to_h do |key, value|
        next [key, value] unless value.is_a?(File)

        [key, Faraday::UploadIO.new(value, mime_type(value.path), value.path)]
      end
    end
  end
end
