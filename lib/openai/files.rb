module OpenAI
  class Files
    def initialize(access_token: nil, organization_id: nil)
      OpenAI.configuration.access_token = access_token if access_token
      OpenAI.configuration.organization_id = organization_id if organization_id
    end

    def list
      OpenAI::Client.get(path: "/files")
    end

    def upload(parameters: {})
      validate(file: parameters[:file])

      OpenAI::Client.multipart_post(
        path: "/files",
        parameters: parameters.merge(file: File.open(parameters[:file]))
      )
    end

    def retrieve(id:)
      OpenAI::Client.get(path: "/files/#{id}")
    end

    def content(id:)
      OpenAI::Client.get(path: "/files/#{id}/content")
    end

    def delete(id:)
      OpenAI::Client.delete(path: "/files/#{id}")
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
