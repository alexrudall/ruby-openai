require_relative "turns/items"

module OpenAI
  class Agents
    class Sessions
      class Subagents
        class Turns
          def initialize(client:)
            @client = client
          end

          def retrieve(session_id:, subagent_id:, id:)
            @client.get(path: "/agents/sessions/#{session_id}/subagents/#{subagent_id}/turns/#{id}")
          end

          def list(session_id:, subagent_id:, parameters: {})
            @client.get(
              path: "/agents/sessions/#{session_id}/subagents/#{subagent_id}/turns",
              parameters: parameters
            )
          end

          def items
            @items ||= OpenAI::Agents::Sessions::Subagents::Turns::Items.new(client: @client)
          end
        end
      end
    end
  end
end
