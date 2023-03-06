module OpenAI
  module Images
    def self.generate(parameters: {})
      OpenAI::Client.json_post(path: "/images/generations", parameters: parameters)
    end

    def self.edit(parameters: {})
      OpenAI::Client.multipart_post(path: "/images/edits", parameters: open_files(parameters))
    end

    def self.variations(parameters: {})
      OpenAI::Client.multipart_post(path: "/images/variations", parameters: open_files(parameters))
    end

    private

    def self.open_files(parameters)
      parameters = parameters.merge(image: File.open(parameters[:image]))
      parameters = parameters.merge(mask: File.open(parameters[:mask])) if parameters[:mask]
      parameters
    end
  end
end
