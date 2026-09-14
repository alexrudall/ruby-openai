module OpenAI
  class Agents
    class Environments
      class Templates
        def initialize(client:)
          @client = client
        end

        def create(parameters: {})
          @client.json_post(path: "/agents/environments/templates", parameters: parameters)
        end

        def retrieve(id:)
          @client.get(path: "/agents/environments/templates/#{id}")
        end

        def update(id:, parameters: {})
          @client.json_post(path: "/agents/environments/templates/#{id}", parameters: parameters)
        end

        def list(parameters: {})
          @client.get(path: "/agents/environments/templates", parameters: parameters)
        end

        def delete(id:)
          @client.delete(path: "/agents/environments/templates/#{id}")
        end
      end
    end
  end
end
