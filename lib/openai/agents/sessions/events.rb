module OpenAI
  class Agents
    class Sessions
      class Events
        def initialize(client:)
          @client = client
        end

        # Submit message, cancel, or tool result events to a session.
        def create(session_id:, parameters: {}, idempotency_key: nil)
          headers = idempotency_key ? { "Idempotency-Key" => idempotency_key } : {}
          @client.json_post(
            path: "/agents/sessions/#{session_id}/events",
            parameters: parameters,
            headers: headers
          )
        end

        # Stream live events for a session over SSE. The connection stays open until
        # the server closes it, so this blocks the calling thread.
        def stream(session_id:, stream:)
          @client.get(path: "/agents/sessions/#{session_id}/events", stream: stream)
        end
      end
    end
  end
end
