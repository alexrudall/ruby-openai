module OpenAI
  class Client
    include HTTParty
    base_uri "https://api.openai.com"

    def initialize(access_token: nil)
      @access_token = access_token || ENV.fetch("OPENAI_ACCESS_TOKEN")
    end

    def answers(version: default_version, parameters: {})
      post(url: "/#{version}/answers", parameters: parameters)
    end

    def classifications(version: default_version, parameters: {})
      post(url: "/#{version}/classifications", parameters: parameters)
    end

    def completions(engine: nil, version: default_version, parameters: {})
      if engine
        post(url: "/#{version}/engines/#{engine}/completions", parameters: parameters)
      else
        post(url: "/#{version}/completions", parameters: parameters)
      end
    end

    def embeddings(engine:, version: default_version, parameters: {})
      post(url: "/#{version}/engines/#{engine}/embeddings", parameters: parameters)
    end

    def engines
      @engines ||= OpenAI::Engines.new(access_token: @access_token)
    end

    def files
      @files ||= OpenAI::Files.new(access_token: @access_token)
    end

    def finetunes
      @finetunes ||= OpenAI::Finetunes.new(access_token: @access_token)
    end

    # rubocop:disable Layout/LineLength
    # rubocop:disable Metrics/ParameterLists
    def search(engine:, query: nil, documents: nil, file: nil, version: default_version, parameters: {})
      return legacy_search(engine: engine, query: query, documents: documents, file: file, version: version) if query || documents || file

      post(url: "/#{version}/engines/#{engine}/search", parameters: parameters)
    end
    # rubocop:enable Layout/LineLength
    # rubocop:enable Metrics/ParameterLists

    private

    # rubocop:disable Layout/LineLength
    def legacy_search(engine:, query:, documents: nil, file: nil, version: default_version)
      warn "[DEPRECATION] Passing `query`, `documents` or `file` directly to `Client#search` is deprecated and will be removed in a future version of ruby-openai.
        Please nest these terms within `parameters` instead, like this:
        client.search(engine: 'davinci', parameters: { query: 'president', documents: %w[washington hospital school] })
      "

      post(
        url: "/#{version}/engines/#{engine}/search",
        parameters: { query: query }.merge(documents_or_file(documents: documents, file: file))
      )
    end
    # rubocop:enable Layout/LineLength

    def default_version
      "v1".freeze
    end

    def documents_or_file(documents: nil, file: nil)
      documents ? { documents: documents } : { file: file }
    end

    def post(url:, parameters:)
      self.class.post(
        url,
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}"
        },
        body: parameters.to_json
      )
    end
  end
end
