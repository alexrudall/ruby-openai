module OpenAI
  module ClientApi
    class Root
      def initialize(client: nil)
        @client = client
      end

      def completions(parameters:)
        raise MissingRequiredParameterError.new(:model) unless parameters[:model]

        @client.json_post(path: "/completions", parameters: parameters)
      end

      def edits(parameters:)
        raise MissingRequiredParameterError.new(:model) unless parameters[:model]
        raise MissingRequiredParameterError.new(:instruction) unless parameters[:instruction]

        @client.json_post(path: "/edits", parameters: parameters)
      end

      def embeddings(parameters:)
        raise MissingRequiredParameterError.new(:model) unless parameters[:model]
        raise MissingRequiredParameterError.new(:input) unless parameters[:input]

        @client.json_post(path: "/embeddings", parameters: parameters)
      end

      def moderations(parameters:)
        raise MissingRequiredParameterError.new(:input) unless parameters[:input]

        @client.json_post(path: "/moderations", parameters: parameters)
      end
    end
  end
end
