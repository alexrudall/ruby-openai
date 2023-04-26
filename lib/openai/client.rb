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
      to_json(conn.get(uri(path: path), timeout: OpenAI.configuration.request_timeout) do |req|
        req.headers = headers
      end&.body)
    end

    def self.json_post(path:, parameters:)
      to_json(conn.post(uri(path: path), timeout: OpenAI.configuration.request_timeout) do |req|
        if parameters[:stream].is_a?(Proc)
          req.options.on_data = to_json_stream(user_proc: parameters[:stream])
          parameters[:stream] = true # Necessary to tell OpenAI to stream.
        end

        req.headers = headers
        req.body = parameters.to_json
      end&.body)
    end

    def self.multipart_post(path:, parameters: nil)
      m_conn = Faraday.new { |f| f.request :multipart }

      to_json(m_conn.post(uri(path: path), timeout: OpenAI.configuration.request_timeout) do |req|
        req.headers = headers.merge({ "Content-Type" => "multipart/form-data" })
        req.body = multipart_parameters(parameters)
      end&.body)
    end

    def self.delete(path:)
      to_json(conn.delete(uri(path: path), timeout: OpenAI.configuration.request_timeout) do |req|
        req.headers = headers
      end&.body)
    end

    def self.to_json(string)
      return unless string

      JSON.parse(string)
    rescue JSON::ParserError
      # Convert a multiline string of JSON objects to a JSON array.
      JSON.parse(string.gsub("}\n{", "},{").prepend("[").concat("]"))
    end

    # Given a proc, returns an outer proc that can be used to iterate over a JSON stream of chunks.
    # For each chunk, the inner user_proc is called giving it the JSON object. The JSON object could be a
    # data object or an error object as described in the OpenAI API documentation.
    #
    # If the JSON object for a given data or error message is invalid, it is ignored.
    #
    # @param user_proc [Proc] The inner proc to call for each JSON object in the chunk.
    # @return [Proc] An outer proc that can be used to iterate over the JSON stream.
    def self.to_json_stream(user_proc:)
      proc do |chunk, _|
        chunk.scan(/(?:data|error): (\{.*\})/i).flatten.each do |data|
          user_proc.call(JSON.parse(data))
        rescue JSON::ParserError
          # Ignore invalid JSON.
        end
      end
    end

    private_class_method def self.conn
      Faraday.new
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

    private_class_method def self.multipart_parameters(parameters)
      parameters&.transform_values do |value|
        next value unless value.is_a?(File)

        # Doesn't seem like OpenAI need mime_type yet, so not worth
        # the library to figure this out. Hence the empty string
        # as the second argument.
        Faraday::UploadIO.new(value, "", value.path)
      end
    end
  end
end
