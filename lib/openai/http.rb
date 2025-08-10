require "event_stream_parser"

require_relative "http_headers"

module OpenAI
  module HTTP
    include HTTPHeaders

    def get(path:, parameters: nil)
      parse_json(conn.get(uri(path: path), parameters) do |req|
        req.headers = headers
      end&.body)
    end

    def post(path:)
      parse_json(conn.post(uri(path: path)) do |req|
        req.headers = headers
      end&.body)
    end

    def json_post(path:, parameters:, query_parameters: {})
      parse_json(conn.post(uri(path: path)) do |req|
        configure_json_post_request(req, parameters)
        req.params = req.params.merge(query_parameters)
      end&.body)
    end

    def multipart_post(path:, parameters: nil)
      parse_json(conn(multipart: true).post(uri(path: path)) do |req|
        req.headers = headers.merge({ "Content-Type" => "multipart/form-data" })
        req.body = multipart_parameters(parameters)
      end&.body)
    end

    def delete(path:)
      parse_json(conn.delete(uri(path: path)) do |req|
        req.headers = headers
      end&.body)
    end

    private

    def parse_json(response)
      return unless response
      return response unless response.is_a?(String)

      original_response = response.dup
      if response.include?("}\n{")
        # Attempt to convert what looks like a multiline string of JSON objects to a JSON array.
        response = response.gsub("}\n{", "},{").prepend("[").concat("]")
      end

      JSON.parse(response)
    rescue JSON::ParserError
      original_response
    end

    def conn(multipart: false)
      connection = Faraday.new do |f|
        f.options[:timeout] = @request_timeout
        f.request(:multipart) if multipart
        f.use MiddlewareErrors if @log_errors
        f.response :raise_error
        f.response :json
      end

      @faraday_middleware&.call(connection)

      connection
    end

    def uri(path:)
      if azure?
        base = File.join(@uri_base, path)
        "#{base}?api-version=#{@api_version}"
      elsif @uri_base.include?(@api_version)
        File.join(@uri_base, path)
      else
        File.join(@uri_base, @api_version, path)
      end
    end

    def multipart_parameters(parameters)
      parameters&.transform_values do |value|
        next value unless value.respond_to?(:close) # File or IO object.

        # Faraday::UploadIO does not require a path, so we will pass it
        # only if it is available. This allows StringIO objects to be
        # passed in as well.
        path = value.respond_to?(:path) ? value.path : nil
        # Doesn't seem like OpenAI needs mime_type yet, so not worth
        # the library to figure this out. Hence the empty string
        # as the second argument.
        Faraday::UploadIO.new(value, "", path)
      end
    end

    def configure_json_post_request(req, parameters)
      req_parameters = parameters.dup

      if parameters[:stream].respond_to?(:call)
        req.options.on_data = Stream.new(user_proc: parameters[:stream]).to_proc
        req_parameters[:stream] = true # Necessary to tell OpenAI to stream.
      elsif parameters[:stream]
        raise ArgumentError, "The stream parameter must be a Proc or have a #call method"
      end

      req.headers = headers
      req.body = req_parameters.to_json
    end
  end
end
