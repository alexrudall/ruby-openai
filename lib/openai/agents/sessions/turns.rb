module OpenAI
  class Agents
    class Sessions
      class Turns
        def initialize(client:)
          @client = client
        end

        def retrieve(session_id:, id:)
          @client.get(path: "/agents/sessions/#{session_id}/turns/#{id}")
        end

        def list(session_id:, parameters: {})
          @client.get(path: "/agents/sessions/#{session_id}/turns", parameters: parameters)
        end
      end
    end
  end
end
