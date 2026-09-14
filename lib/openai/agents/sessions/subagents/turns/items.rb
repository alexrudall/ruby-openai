module OpenAI
  class Agents
    class Sessions
      class Subagents
        class Turns
          class Items
            def initialize(client:)
              @client = client
            end

            def list(session_id:, subagent_id:, turn_id:, parameters: {})
              base = "/agents/sessions/#{session_id}/subagents/#{subagent_id}"
              @client.get(path: "#{base}/turns/#{turn_id}/items", parameters: parameters)
            end
          end
        end
      end
    end
  end
end
