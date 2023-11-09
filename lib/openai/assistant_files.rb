# frozen_string_literal: true

module OpenAI
  class AssistantFiles
    class InvalidFileFormat < OpenAI::Error; end

    VALID_EXTENSIONS = %w[
      .csv .docx .html .java .json .md .pdf .php .pptx .py .rb .tex .txt .css .jpeg .jpg .js .gif
      .png .tar .ts .xlsx .xml .zip
    ].freeze

    def initialize(client:, assistant_id:)
      @client = client.beta(assistants: "v1")
      @assistant_id = assistant_id
    end

    def list
      @client.get(path: "/assistants/#{@assistant_id}/files")
    end

    def upload(parameters: {})
      validate(file: parameters[:file])

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

    private

    def validate(file:)
      file_extension = File.extname(file)
      return if VALID_EXTENSIONS.include?(file_extension)

      raise(
        InvalidFileFormat,
        "Invalid file format. Supported formats: #{VALID_EXTENSIONS.join(', ')}"
      )
    end
  end
end
