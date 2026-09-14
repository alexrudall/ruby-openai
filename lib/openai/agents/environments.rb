require_relative "environments/files"
require_relative "environments/templates"

module OpenAI
  class Agents
    class Environments
      def initialize(client:)
        @client = client
      end

      def retrieve(id:)
        @client.get(path: "/agents/environments/#{id}")
      end

      def files
        @files ||= OpenAI::Agents::Environments::Files.new(client: @client)
      end

      def templates
        @templates ||= OpenAI::Agents::Environments::Templates.new(client: @client)
      end
    end
  end
end
