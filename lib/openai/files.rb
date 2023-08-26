module OpenAI
  class Files
    def initialize(client:)
      @client = client
    end

    def list
      @client.get(path: "/files")
    end

    def upload(parameters: {})
      validate(file: parameters[:file])

      @client.multipart_post(
        path: "/files",
        parameters: parameters.merge(file: File.open(parameters[:file]))
      )
    end

    def retrieve(id:)
      @client.get(path: "/files/#{id}")
    end

    def content(id:)
      @client.get(path: "/files/#{id}/content")
    end

    def delete(id:)
      @client.delete(path: "/files/#{id}")
    end

    private

    def validate(file:)
      File.open(file).each_line.with_index do |line, index|
        JSON.parse(line)
      rescue JSON::ParserError => e
        raise JSON::ParserError, "#{e.message} - found on line #{index + 1} of #{file}"
      end
    end
  end
end
