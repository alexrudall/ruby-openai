module OpenAI
  class Images
    def initialize(client: nil, access_token: nil,
                   organization_id: OpenAI::Client::NULL_ORGANIZATION_ID)
      @client = if client.nil?
                  OpenAI::Client.new(access_token: access_token, organization_id: organization_id)
                else
                  client
                end
    end

    def generate(parameters: {})
      @client.json_post(path: "/images/generations", parameters: parameters)
    end

    def edit(parameters: {})
      @client.multipart_post(path: "/images/edits", parameters: open_files(parameters))
    end

    def variations(parameters: {})
      @client.multipart_post(path: "/images/variations", parameters: open_files(parameters))
    end

    private

    def open_files(parameters)
      parameters = parameters.merge(image: File.open(parameters[:image]))
      parameters = parameters.merge(mask: File.open(parameters[:mask])) if parameters[:mask]
      parameters
    end
  end
end
