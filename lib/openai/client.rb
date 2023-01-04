require "forwardable"
require "httparty"
require_relative "client_api/files"
require_relative "client_api/finetunes"
require_relative "client_api/images"
require_relative "client_api/models"
require_relative "client_api/root"

module OpenAI
  class Client
    extend Forwardable

    URI_BASE = "https://api.openai.com/".freeze

    NULL_ORGANIZATION_ID = Object.new.freeze

    attr_reader :access_token, :organization_id, :api_version

    def initialize(access_token: nil, organization_id: NULL_ORGANIZATION_ID, api_version: nil)
      @access_token = access_token || OpenAI.configuration.access_token
      initialize_organization_id(organization_id: organization_id)
      @api_version = api_version || OpenAI.configuration.api_version

      raise OpenAI::MissingAccessTokenError unless @access_token
    end

    def initialize_organization_id(organization_id:)
      @organization_id = if organization_id == NULL_ORGANIZATION_ID
                           OpenAI.configuration.access_token
                         else
                           organization_id
                         end
    end

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

    def headers(content_type: "application/json")
      {
        "Content-Type" => content_type
      }.merge(openai_headers)
    end

    def openai_headers
      @openai_headers ||=
        if organization_id.nil?
          auth_headers
        else
          auth_headers.merge(
            { "OpenAI-Organization" => organization_id }
          )
        end
    end

    def auth_headers
      @auth_headers ||= { "Authorization" => "Bearer #{access_token}" }
    end
  end
end
