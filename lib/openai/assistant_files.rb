# frozen_string_literal: true

module OpenAI
  class AssistantFiles
    def initialize(client:, assistant_id:)
      @client = client.beta(assistants: "v1")
      @assistant_id = assistant_id
    end

    def list
      @client.get(path: "/assistants/#{@assistant_id}/files")
    end

    def upload(parameters: {})
      @client.multipart_post(
        path: "/files",
        parameters: parameters.merge(
          file: File.open(parameters[:file]),
          purpose: "assistants"
        )
      )
    end

    def create(file_id:)
      @client.json_post(
        path: "/assistants/#{@assistant_id}/files",
        parameters: { file_id: file_id }
      )
    end

    def retrieve(id:)
      @client.get(path: "/assistants/#{@assistant_id}/files/#{id}")
    end

    def delete(id:)
      @client.delete(path: "/assistants/#{@assistant_id}/files/#{id}")
    end
  end
end
