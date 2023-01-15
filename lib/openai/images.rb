module OpenAI
  class Images
    def initialize(access_token: nil, organization_id: nil)
      OpenAI.configuration.access_token = access_token if access_token
      OpenAI.configuration.organization_id = organization_id if organization_id
    end

    def generate(parameters: {})
      OpenAI::Client.json_post(path: "/images/generations", parameters: parameters)
    end

    def edit(parameters: {})
      OpenAI::Client.multipart_post(path: "/images/edits", parameters: open_files(parameters))
    end

    def variations(parameters: {})
      OpenAI::Client.multipart_post(path: "/images/variations", parameters: open_files(parameters))
    end

    private

    def open_files(parameters)
      parameters = parameters.merge(image: File.open(parameters[:image]))
      parameters = parameters.merge(mask: File.open(parameters[:mask])) if parameters[:mask]
      parameters
    end
  end
end
