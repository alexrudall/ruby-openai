module OpenAI
  class Agents
    class Vaults
      class Credentials
        def initialize(client:)
          @client = client
        end

        def create(vault_id:, parameters: {})
          @client.json_post(path: "/vaults/#{vault_id}/credentials", parameters: parameters)
        end

        def retrieve(vault_id:, id:)
          @client.get(path: "/vaults/#{vault_id}/credentials/#{id}")
        end

        def update(vault_id:, id:, parameters: {})
          @client.json_post(path: "/vaults/#{vault_id}/credentials/#{id}", parameters: parameters)
        end

        def list(vault_id:, parameters: {})
          @client.get(path: "/vaults/#{vault_id}/credentials", parameters: parameters)
        end

        def delete(vault_id:, id:)
          @client.delete(path: "/vaults/#{vault_id}/credentials/#{id}")
        end
      end
    end
  end
end
