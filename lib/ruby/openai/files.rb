module OpenAI
  class Files
    include HTTParty
    base_uri "https://api.openai.com"

    def initialize(access_token: nil, organization_id: nil)
      Ruby::OpenAI.configuration.access_token = access_token if access_token
      Ruby::OpenAI.configuration.organization_id = organization_id if organization_id
    end

    def list(version: default_version)
      self.class.get(
        "/#{version}/files",
        headers: Ruby::OpenAI.headers
      )
    end

    def upload(version: default_version, parameters: {})
      validate(file: parameters[:file])

      self.class.post(
        "/#{version}/files",
        headers: Ruby::OpenAI.headers,
        body: parameters.merge(file: File.open(parameters[:file]))
      )
    end

    def retrieve(id:, version: default_version)
      self.class.get(
        "/#{version}/files/#{id}",
        headers: Ruby::OpenAI.headers
      )
    end

    def delete(id:, version: default_version)
      self.class.delete(
        "/#{version}/files/#{id}",
        headers: Ruby::OpenAI.headers
      )
    end

    private

    def default_version
      "v1".freeze
    end

    def validate(file:)
      File.open(file).each_line.with_index do |line, index|
        JSON.parse(line)
      rescue JSON::ParserError => e
        raise JSON::ParserError, "#{e.message} - found on line #{index + 1} of #{file}"
      end
    end
  end
end
