module OpenAI
  class Images
    include HTTParty
    base_uri "https://api.openai.com"

    def initialize(access_token: nil, organization_id: nil)
      @access_token = access_token || Ruby::OpenAI.configuration.access_token
      @organization_id = organization_id || Ruby::OpenAI.configuration.organization_id
    end

    def generate(version: default_version, parameters: {})
      self.class.post(
        "/#{version}/images/generations",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}",
          "OpenAI-Organization" => @organization_id
        },
        body: parameters.to_json
      )
    end

    def edit(version: default_version, parameters: {})
      parameters = open_files(parameters)

      self.class.post(
        "/#{version}/images/edits",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}",
          "OpenAI-Organization" => @organization_id
        },
        body: parameters
      )
    end

    def variations(version: default_version, parameters: {})
      parameters = open_files(parameters)

      self.class.post(
        "/#{version}/images/variations",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{@access_token}",
          "OpenAI-Organization" => @organization_id
        },
        body: parameters
      )
    end

    private

    def default_version
      "v1".freeze
    end

    def open_files(parameters)
      parameters = parameters.merge(image: File.open(parameters[:image]))
      parameters = parameters.merge(mask: File.open(parameters[:mask])) if parameters[:mask]
      parameters
    end
  end
end
