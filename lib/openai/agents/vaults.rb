require_relative "vaults/credentials"

module OpenAI
  class Agents
    class Vaults
      def initialize(client:)
        @client = client
      end

      def create(parameters: {})
        @client.json_post(path: "/vaults", parameters: parameters)
      end

      def retrieve(id:)
        @client.get(path: "/vaults/#{id}")
      end

      def list(parameters: {})
        @client.get(path: "/vaults", parameters: parameters)
      end

      def delete(id:)
        @client.delete(path: "/vaults/#{id}")
      end

      def credentials
        @credentials ||= OpenAI::Agents::Vaults::Credentials.new(client: @client)
      end
    end
  end
end
