module OpenAI
  class Agents
    class Sessions
      class Items
        def initialize(client:)
          @client = client
        end

        def list(session_id:, parameters: {})
          @client.get(path: "/agents/sessions/#{session_id}/items", parameters: parameters)
        end
      end
    end
  end
end
