module OpenAI
  class Images
    def initialize(access_token: nil, organization_id: nil)
      Ruby::OpenAI.configuration.access_token = access_token if access_token
      Ruby::OpenAI.configuration.organization_id = organization_id if organization_id
    end

    def generate(version: Ruby::OpenAI.api_version, parameters: {})
      OpenAI::Client.post(path: "/#{version}/images/generations", parameters: parameters.to_json)
    end

    def edit(version: Ruby::OpenAI.api_version, parameters: {})
      OpenAI::Client.post(path: "/#{version}/images/edits", parameters: open_files(parameters))
    end

    def variations(version: Ruby::OpenAI.api_version, parameters: {})
      OpenAI::Client.post(path: "/#{version}/images/variations", parameters: open_files(parameters))
    end

    private

    def open_files(parameters)
      parameters = parameters.merge(image: File.open(parameters[:image]))
      parameters = parameters.merge(mask: File.open(parameters[:mask])) if parameters[:mask]
      parameters
    end
  end
end
