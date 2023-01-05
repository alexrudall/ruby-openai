module OpenAI
  module ClientApi
    class Finetunes
      def initialize(client: nil)
        @client = client
      end

      def list
        @client.get(path: "/fine-tunes")
      end

      def create(parameters:)
        raise MissingRequiredParameterError.new(:training_file) unless parameters[:training_file]

        @client.json_post(path: "/fine-tunes", parameters: parameters)
      end

      def retrieve(id:)
        @client.get(path: "/fine-tunes/#{id}")
      end

      def cancel(id:)
        @client.multipart_post(path: "/fine-tunes/#{id}/cancel")
      end

      def events(id:)
        @client.get(path: "/fine-tunes/#{id}/events")
      end
    end
  end
end
