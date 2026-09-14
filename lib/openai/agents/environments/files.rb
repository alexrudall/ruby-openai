module OpenAI
  class Agents
    class Environments
      class Files
        def initialize(client:)
          @client = client
        end

        # Copy inline bytes (`type: "inline"`) or a Files API file (`type: "file_id"`) into
        # a connected execution environment.
        def create(environment_id:, parameters: {})
          @client.json_post(
            path: "/agents/environments/#{environment_id}/files",
            parameters: parameters
          )
        end

        def list(environment_id:, parameters: {})
          @client.get(path: "/agents/environments/#{environment_id}/files", parameters: parameters)
        end
      end
    end
  end
end
