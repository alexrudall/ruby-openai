module OpenAI
  class Agents
    class Sessions
      class Subagents
        class Items
          def initialize(client:)
            @client = client
          end

          def list(session_id:, subagent_id:, parameters: {})
            @client.get(
              path: "/agents/sessions/#{session_id}/subagents/#{subagent_id}/items",
              parameters: parameters
            )
          end
        end
      end
    end
  end
end
