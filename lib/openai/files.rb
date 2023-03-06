module OpenAI
  module Files
    def self.list
      OpenAI::Client.get(path: "/files")
    end

    def self.upload(parameters: {})
      validate(file: parameters[:file])

      OpenAI::Client.multipart_post(
        path: "/files",
        parameters: parameters.merge(file: File.open(parameters[:file]))
      )
    end

    def self.retrieve(id:)
      OpenAI::Client.get(path: "/files/#{id}")
    end

    def self.content(id:)
      OpenAI::Client.get(path: "/files/#{id}/content")
    end

    def self.delete(id:)
      OpenAI::Client.delete(path: "/files/#{id}")
    end

    private

    def self.validate(file:)
      File.open(file).each_line.with_index do |line, index|
        JSON.parse(line)
      rescue JSON::ParserError => e
        raise JSON::ParserError, "#{e.message} - found on line #{index + 1} of #{file}"
      end
    end
  end
end
