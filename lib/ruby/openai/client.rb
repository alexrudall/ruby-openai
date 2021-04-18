module OpenAI
  class Client
    include HTTParty
    base_uri "https://api.openai.com"

    def initialize(access_token: nil)
      @access_token = access_token || ENV["OPENAI_ACCESS_TOKEN"]
    end

    def answers(version: default_version, parameters: {})
      self.class.post(
        "/#{version}/answers",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}"
        },
        body: parameters.to_json
      )
    end

    def classifications(version: default_version, parameters: {})
      self.class.post(
        "/#{version}/classifications",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}"
        },
        body: parameters.to_json
      )
    end

    def completions(engine:, version: default_version, parameters: {})
      self.class.post(
        "/#{version}/engines/#{engine}/completions",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}"
        },
        body: parameters.to_json
      )
    end

    def files
      @files ||= OpenAI::Files.new(access_token: @access_token)
    end

    # rubocop:disable Layout/LineLength
    # rubocop:disable Metrics/ParameterLists
    def search(engine:, query: nil, documents: nil, file: nil, version: default_version, parameters: {})
      return legacy_search(engine: engine, query: query, documents: documents, file: file, version: version) if query || documents || file

      self.class.post(
        "/#{version}/engines/#{engine}/search",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}"
        },
        body: parameters.to_json
      )
    end
    # rubocop:enable Layout/LineLength
    # rubocop:enable Metrics/ParameterLists

    private

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Layout/LineLength
    def legacy_search(engine:, query:, documents: nil, file: nil, version: default_version)
      warn "[DEPRECATION] Passing `query`, `documents` or `file` directly to `Client#search` is deprecated and will be removed in a future version of ruby-openai.
        Please nest these terms within `parameters` instead, like this:
        client.search(engine: 'davinci', parameters: { query: 'president', documents: %w[washington hospital school] })
      "
      self.class.post(
        "/#{version}/engines/#{engine}/search",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}"
        },
        body: { query: query }.merge(documents_or_file(documents: documents, file: file)).to_json
      )
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Layout/LineLength

    def default_version
      "v1".freeze
    end

    def documents_or_file(documents: nil, file: nil)
      documents ? { documents: documents } : { file: file }
    end
  end
end
