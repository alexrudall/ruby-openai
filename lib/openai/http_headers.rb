module OpenAI
  module HTTPHeaders
    def add_headers(headers)
      @extra_headers = extra_headers.merge(headers.transform_keys(&:to_s))
    end

    private

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
      }.merge(azure_auth_headers)
    end

    def azure_auth_headers
      if @access_token
        { "api-key" => @access_token }
      elsif @azure_token_provider
        { "Authorization" => "Bearer #{@azure_token_provider.call}" }
      else
        raise ConfigurationError, "access_token or azure_token_provider must be set."
      end
    end

    def extra_headers
      @extra_headers ||= {}
    end
  end
end
