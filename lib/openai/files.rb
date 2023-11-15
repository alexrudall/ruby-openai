module OpenAI
  class Files
    def initialize(client:)
      @client = client
    end

    def list
      @client.get(path: "/files")
    end

    def upload(parameters: {})
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
  end
end
