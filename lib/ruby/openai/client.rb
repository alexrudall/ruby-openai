module OpenAI
  class Client
    include HTTParty
    base_uri "https://api.openai.com"

    def initialize(access_token: nil, organization_id: nil)
      Ruby::OpenAI.configuration.access_token = access_token if access_token
      Ruby::OpenAI.configuration.organization_id = organization_id if organization_id
    end

    def answers(version: Ruby::OpenAI.api_version, parameters: {})
      warn "[DEPRECATION WARNING] [ruby-openai] `Client#answers` is deprecated and will
      be removed from the OpenAI API on 3 December 2022 and from ruby-openai v3.0.
      More information: https://help.openai.com/en/articles/6233728-answers-transition-guide"

      post(url: "/#{version}/answers", parameters: parameters)
    end

    def classifications(version: Ruby::OpenAI.api_version, parameters: {})
      warn "[DEPRECATION WARNING] [ruby-openai] `Client#classifications` is deprecated and will
      be removed from the OpenAI API on 3 December 2022 and from ruby-openai v3.0.
      More information: https://help.openai.com/en/articles/6272941-classifications-transition-guide"

      post(url: "/#{version}/classifications", parameters: parameters)
    end

    def completions(engine: nil, version: Ruby::OpenAI.api_version, parameters: {})
      parameters = deprecate_engine(engine: engine, method: "completions", parameters: parameters)

      post(url: "/#{version}/completions", parameters: parameters)
    end

    def edits(version: Ruby::OpenAI.api_version, parameters: {})
      post(url: "/#{version}/edits", parameters: parameters)
    end

    def embeddings(engine: nil, version: Ruby::OpenAI.api_version, parameters: {})
      parameters = deprecate_engine(engine: engine, method: "embeddings", parameters: parameters)

      post(url: "/#{version}/embeddings", parameters: parameters)
    end

    def engines
      warn "[DEPRECATION WARNING] [ruby-openai] `Client#engines` is deprecated and will
      be removed from ruby-openai v3.0. Use `Client#models` instead."

      @engines ||= OpenAI::Engines.new
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

    def moderations(version: Ruby::OpenAI.api_version, parameters: {})
      post(url: "/#{version}/moderations", parameters: parameters)
    end

    def search(engine:, version: Ruby::OpenAI.api_version, parameters: {})
      warn "[DEPRECATION WARNING] [ruby-openai] `Client#search` is deprecated and will
      be removed from the OpenAI API on 3 December 2022 and from ruby-openai v3.0.
      More information: https://help.openai.com/en/articles/6272952-search-transition-guide"

      post(url: "/#{version}/engines/#{engine}/search", parameters: parameters)
    end

    private

    def deprecate_engine(engine:, method:, parameters:)
      return parameters unless engine

      parameters = { model: engine }.merge(parameters)

      warn "[DEPRECATION WARNING] [ruby-openai] Passing `engine` directly to `Client##{method}` is
      deprecated and will be removed in ruby-openai 3.0. Pass `model` within `parameters` instead:
      client.completions(parameters: { #{parameters.map { |k, v| "#{k}: \"#{v}\"" }.join(', ')} })"

      parameters
    end

    def documents_or_file(documents: nil, file: nil)
      documents ? { documents: documents } : { file: file }
    end

    def post(url:, parameters:)
      self.class.post(
        url,
        headers: Ruby::OpenAI.headers,
        body: parameters.to_json
      )
    end
  end
end
