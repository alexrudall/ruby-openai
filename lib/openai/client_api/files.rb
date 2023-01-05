require_relative "../jsonl_validator"

module OpenAI
  module ClientApi
    class Files
      def initialize(client: nil)
        @client = client
      end

      def list
        @client.get(path: "/files")
      end

      def upload(parameters:)
        raise MissingRequiredParameterError.new(:file) unless parameters[:file]
        raise MissingRequiredParameterError.new(:purpose) unless parameters[:purpose]

        validate(file: parameters[:file])

        @client.multipart_post(
          path: "/files",
          parameters: parameters.merge(file: File.open(parameters[:file]))
        )
      end

      def retrieve(id:)
        @client.get(path: "/files/#{id}")
      end

      def delete(id:)
        @client.delete(path: "/files/#{id}")
      end

      private

      def validate(file:)
        JsonlValidator.validate(source: File.open(file))
      end
    end
  end
end
