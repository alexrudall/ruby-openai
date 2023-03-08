module OpenAI
  class Request
    URI_BASE = "https://api.openai.com/".freeze

    def get(path)
      HTTParty.get(
        uri(path),
        headers: headers
      )
    end

    def json_post(path, parameters:)
      HTTParty.post(
        uri(path),
        headers: headers,
        body: parameters&.to_json
      )
    end

    def multipart_post(path, parameters: nil)
      HTTParty.post(
        uri(path),
        headers: headers.merge({ "Content-Type" => "multipart/form-data" }),
        body: parameters
      )
    end

    def delete(path)
      HTTParty.delete(
        uri(path),
        headers: headers
      )
    end

    private
      def uri(path)
        URI_BASE + OpenAI.api_version + path
      end

      def headers
        {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{OpenAI.access_token}",
          "OpenAI-Organization" => OpenAI.organization_id
        }
      end
  end
end
