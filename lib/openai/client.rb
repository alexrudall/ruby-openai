require "forwardable"
require "httparty"
require_relative "headers_factory"
require_relative "client_api/files"
require_relative "client_api/finetunes"
require_relative "client_api/images"
require_relative "client_api/models"
require_relative "client_api/root"

module OpenAI
  class Client
    extend Forwardable

    URI_BASE = "https://api.openai.com/".freeze

    attr_reader :access_token, :organization_id, :api_version

    def initialize(access_token: nil, organization_id: HeadersFactory::NULL_ORGANIZATION_ID,
                   api_version: nil)
      @headers_factory = HeadersFactory.new(access_token: access_token,
                                            organization_id: organization_id)
      @api_version = api_version || OpenAI.configuration.api_version
    end
    def_delegators :@headers_factory, :access_token, :organization_id, :headers

    def files
      @files ||= OpenAI::ClientApi::Files.new(client: self)
    end

    def finetunes
      @finetunes ||= OpenAI::ClientApi::Finetunes.new(client: self)
    end

    def images
      @images ||= OpenAI::ClientApi::Images.new(client: self)
    end

    def models
      @models ||= OpenAI::ClientApi::Models.new(client: self)
    end

    def root
      @root ||= OpenAI::ClientApi::Root.new(client: self)
    end
    def_delegators :root, :completions, :edits, :embeddings, :moderations

    def get(path:)
      HTTParty.get(
        uri(path: path),
        headers: headers
      )
    end

    def json_post(path:, parameters: nil)
      HTTParty.post(
        uri(path: path),
        headers: headers,
        body: parameters&.to_json
      )
    end

    def multipart_post(path:, parameters: nil)
      HTTParty.post(
        uri(path: path),
        headers: headers(content_type: "multipart/form-data"),
        body: parameters
      )
    end

    def delete(path:)
      HTTParty.delete(
        uri(path: path),
        headers: headers
      )
    end

    private

    def uri(path:)
      URI_BASE + api_version + path
    end
  end
end
