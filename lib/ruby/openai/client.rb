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
      parameters = deprecate_engine(engine: engine, method: "completions", parameters: parameters)

      post(url: "/#{version}/completions", parameters: parameters)
    end

    def edits(version: default_version, parameters: {})
      post(url: "/#{version}/edits", parameters: parameters)
    end

    def embeddings(engine: nil, version: default_version, parameters: {})
      parameters = deprecate_engine(engine: engine, method: "embeddings", parameters: parameters)

      post(url: "/#{version}/embeddings", parameters: parameters)
    end

    def files
      @files ||= OpenAI::Files.new(access_token: @access_token)
    end

    def finetunes
      @finetunes ||= OpenAI::Finetunes.new(access_token: @access_token)
    end

    def models
      @models ||= OpenAI::Models.new(access_token: @access_token)
    end

    def moderations(version: default_version, parameters: {})
      post(url: "/#{version}/moderations", parameters: parameters)
    end

    def search(engine:, version: default_version, parameters: {})
      deprecate_search

      post(url: "/#{version}/engines/#{engine}/search", parameters: parameters)
    end

    private

    def deprecate_engine(engine:, method:, parameters:)
      return parameters unless engine

      parameters = { model: engine }.merge(parameters)

      warn "[DEPRECATION WARNING] [ruby-openai] Passing `engine` directly to `Client##{method}` is
      deprecated and will be removed in ruby-openai 3.0. Pass `model` within `parameters` instead:
      client.completions(parameters: { #{parameters.map { |k, v| "#{k}: \"#{v}\"" }.join(', ')} })
      "

      parameters
    end

    def deprecate_search
      warn "[DEPRECATION WARNING] [ruby-openai] `Client#search` is
      deprecated and will be removed from the OpenAI API on 3 December 2022 and from the
      ruby-openai gem in v3.0.
      More information: https://help.openai.com/en/articles/6272952-search-transition-guide
      "
    end

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
