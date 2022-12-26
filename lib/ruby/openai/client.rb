module OpenAI
  class Client
    URI_BASE = "https://api.openai.com/".freeze

    def initialize(access_token: nil, organization_id: nil)
      Ruby::OpenAI.configuration.access_token = access_token if access_token
      Ruby::OpenAI.configuration.organization_id = organization_id if organization_id
    end

    def completions(version: Ruby::OpenAI.configuration.api_version, parameters: {})
      OpenAI::Client.post(path: "/#{version}/completions", parameters: parameters)
    end

    def edits(parameters: {})
      OpenAI::Client.post(path: "/edits", parameters: parameters)
    end

    def embeddings(version: Ruby::OpenAI.configuration.api_version, parameters: {})
      OpenAI::Client.post(path: "/#{version}/embeddings", parameters: parameters)
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
      OpenAI::Client.post(path: "/moderations", parameters: parameters)
    end

    def search(engine:, parameters: {})
      warn "[DEPRECATION WARNING] [ruby-openai] `Client#search` is deprecated and will
      be removed from the OpenAI API on 3 December 2022 and from ruby-openai v3.0.
      More information: https://help.openai.com/en/articles/6272952-search-transition-guide"

      OpenAI::Client.post(path: "/engines/#{engine}/search", parameters: parameters)
    end

    def self.get(path:)
      HTTParty.get(
        uri(path: path),
        headers: headers
      )
    end

    def self.post(path:, parameters: nil)
      HTTParty.post(
        uri(path: path),
        headers: headers,
        body: parameters.to_json
      )
    end

    def self.delete(path:)
      HTTParty.delete(
        uri(path: path),
        headers: headers
      )
    end

    private_class_method def self.uri(path:)
      URI_BASE + Ruby::OpenAI.configuration.api_version + path
    end

    private_class_method def self.headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{Ruby::OpenAI.configuration.access_token}",
        "OpenAI-Organization" => Ruby::OpenAI.configuration.organization_id
      }
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
  end
end
