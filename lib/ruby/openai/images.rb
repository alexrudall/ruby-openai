module OpenAI
  class Images
    include HTTParty
    base_uri "https://api.openai.com"

    def initialize(access_token: nil, organization_id: nil)
      Ruby::OpenAI.configuration.access_token = access_token if access_token
      Ruby::OpenAI.configuration.organization_id = organization_id if organization_id
    end

    def generate(version: Ruby::OpenAI.api_version, parameters: {})
      self.class.post(
        "/#{version}/images/generations",
        headers: Ruby::OpenAI.headers,
        body: parameters.to_json
      )
    end

    def edit(version: Ruby::OpenAI.api_version, parameters: {})
      parameters = open_files(parameters)

      self.class.post(
        "/#{version}/images/edits",
        headers: Ruby::OpenAI.headers,
        body: parameters
      )
    end

    def variations(version: Ruby::OpenAI.api_version, parameters: {})
      parameters = open_files(parameters)

      self.class.post(
        "/#{version}/images/variations",
        headers: Ruby::OpenAI.headers,
        body: parameters
      )
    end

    private

    def open_files(parameters)
      parameters = parameters.merge(image: File.open(parameters[:image]))
      parameters = parameters.merge(mask: File.open(parameters[:mask])) if parameters[:mask]
      parameters
    end
  end
end
