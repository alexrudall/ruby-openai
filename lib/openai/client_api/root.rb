module OpenAI
  module ClientApi
    class Root
      def initialize(client: nil)
        @client = client
      end

      def completions(parameters: {})
        @client.json_post(path: "/completions", parameters: parameters)
      end

      def edits(parameters: {})
        @client.json_post(path: "/edits", parameters: parameters)
      end

      def embeddings(parameters: {})
        @client.json_post(path: "/embeddings", parameters: parameters)
      end

      def moderations(parameters: {})
        @client.json_post(path: "/moderations", parameters: parameters)
      end
    end
  end
end
