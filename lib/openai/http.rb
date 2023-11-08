require "event_stream_parser"

module OpenAI
  module HTTP
    def get(path:)
      parse_jsonl(conn.get(uri(path: path)) do |req|
        req.headers = headers
      end&.body)
    end

    def json_post(path:, parameters:)
      conn.post(uri(path: path)) do |req|
        configure_json_post_request(req, parameters)
      end&.body
    end

    def multipart_post(path:, parameters: nil)
      conn(multipart: true).post(uri(path: path)) do |req|
        req.headers = headers.merge({ "Content-Type" => "multipart/form-data" })
        req.body = multipart_parameters(parameters)
      end&.body
    end

    def delete(path:)
      conn.delete(uri(path: path)) do |req|
        req.headers = headers
      end&.body
    end

    private

    def parse_jsonl(response)
      return unless response
      return response unless response.is_a?(String)

      # Convert a multiline string of JSON objects to a JSON array.
      response = response.gsub("}\n{", "},{").prepend("[").concat("]")

      JSON.parse(response)
    end

    # Given a proc, returns an outer proc that can be used to iterate over a JSON stream of chunks.
    # For each chunk, the inner user_proc is called giving it the JSON object. The JSON object could
    # be a data object or an error object as described in the OpenAI API documentation.
    #
    # @param user_proc [Proc] The inner proc to call for each JSON object in the chunk.
    # @return [Proc] An outer proc that iterates over a raw stream, converting it to JSON.
    def to_json_stream(user_proc:)
      parser = EventStreamParser::Parser.new

      proc do |chunk, _bytes, env|
        if env && env.status != 200
          raise_error = Faraday::Response::RaiseError.new
          raise_error.on_complete(env.merge(body: try_parse_json(chunk)))
        end

        parser.feed(chunk) do |_type, data|
          user_proc.call(JSON.parse(data)) unless data == "[DONE]"
        end
      end
    end

    def conn(multipart: false)
      Faraday.new do |f|
        f.options[:timeout] = @request_timeout
        f.request(:multipart) if multipart
        f.response :raise_error
        f.response :json
      end
    end

    def uri(path:)
      if azure?
        base = File.join(@uri_base, path)
        "#{base}?api-version=#{@api_version}"
      else
        File.join(@uri_base, @api_version, path)
      end
    end

    def headers
      if azure?
        azure_headers
      else
        openai_headers
      end.merge(extra_headers)
    end

    def openai_headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@access_token}",
        "OpenAI-Organization" => @organization_id
      }
    end

    def azure_headers
      {
        "Content-Type" => "application/json",
        "api-key" => @access_token
      }
    end

    def extra_headers
      @extra_headers ||= {}
    end

    def add_headers(headers)
      @extra_headers = extra_headers.merge(headers.transform_keys(&:to_s))
    end

    def multipart_parameters(parameters)
      parameters&.transform_values do |value|
        next value unless value.respond_to?(:close) # File or IO object.

        # Doesn't seem like OpenAI needs mime_type yet, so not worth
        # the library to figure this out. Hence the empty string
        # as the second argument.
        Faraday::UploadIO.new(value, "", value.path)
      end
    end

    def configure_json_post_request(req, parameters)
      req_parameters = parameters.dup

      if parameters[:stream].respond_to?(:call)
        req.options.on_data = to_json_stream(user_proc: parameters[:stream])
        req_parameters[:stream] = true # Necessary to tell OpenAI to stream.
      elsif parameters[:stream]
        raise ArgumentError, "The stream parameter must be a Proc or have a #call method"
      end

      req.headers = headers
      req.body = req_parameters.to_json
    end

    def try_parse_json(maybe_json)
      JSON.parse(maybe_json)
    rescue JSON::ParserError
      maybe_json
    end
  end
end
