module OpenAI
  class Agents
    class Sessions
      class Artifacts
        def initialize(client:)
          @client = client
        end

        def retrieve(session_id:, id:)
          @client.get(path: "/agents/sessions/#{session_id}/artifacts/#{id}")
        end

        def list(session_id:, parameters: {})
          @client.get(path: "/agents/sessions/#{session_id}/artifacts", parameters: parameters)
        end

        def delete(session_id:, id:)
          @client.delete(path: "/agents/sessions/#{session_id}/artifacts/#{id}")
        end

        # Download the artifact's raw bytes. Returns a String.
        def content(session_id:, id:)
          @client.get(
            path: "/agents/sessions/#{session_id}/artifacts/#{id}/content",
            headers: { "Accept" => "application/octet-stream" }
          )
        end
      end
    end
  end
end
