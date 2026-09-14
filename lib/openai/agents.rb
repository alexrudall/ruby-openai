require_relative "agents/sessions"
require_relative "agents/environments"
require_relative "agents/vaults"

module OpenAI
  class Agents
    BETA_VERSION = "v1".freeze

    def initialize(client:)
      @client = client.beta(agents: BETA_VERSION)
    end

    def create(parameters: {})
      @client.json_post(path: "/agents", parameters: parameters)
    end

    def retrieve(id:)
      @client.get(path: "/agents/#{id}")
    end

    def update(id:, parameters: {})
      @client.json_post(path: "/agents/#{id}", parameters: parameters)
    end

    def list(parameters: {})
      @client.get(path: "/agents", parameters: parameters)
    end

    def delete(id:)
      @client.delete(path: "/agents/#{id}")
    end

    def sessions
      @sessions ||= OpenAI::Agents::Sessions.new(client: @client)
    end

    def environments
      @environments ||= OpenAI::Agents::Environments.new(client: @client)
    end

    def vaults
      @vaults ||= OpenAI::Agents::Vaults.new(client: @client)
    end
  end
end
