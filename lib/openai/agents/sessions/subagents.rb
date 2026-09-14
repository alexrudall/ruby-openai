require_relative "subagents/items"
require_relative "subagents/turns"

module OpenAI
  class Agents
    class Sessions
      class Subagents
        def initialize(client:)
          @client = client
        end

        def retrieve(session_id:, id:)
          @client.get(path: "/agents/sessions/#{session_id}/subagents/#{id}")
        end

        def list(session_id:, parameters: {})
          @client.get(path: "/agents/sessions/#{session_id}/subagents", parameters: parameters)
        end

        def items
          @items ||= OpenAI::Agents::Sessions::Subagents::Items.new(client: @client)
        end

        def turns
          @turns ||= OpenAI::Agents::Sessions::Subagents::Turns.new(client: @client)
        end
      end
    end
  end
end
