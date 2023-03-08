module OpenAI
  module Files
    def files
      get("/files")
    end

    def upload_file(parameters: {})
      validate(file: parameters[:file])

      multipart_post(
        "/files",
        parameters: parameters.merge(file: File.open(parameters[:file]))
      )
    end

    def file(id:)
      get("/files/#{id}")
    end

    def file_content(id:)
      get("/files/#{id}/content")
    end

    def delete_file(id:)
      delete("/files/#{id}")
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
