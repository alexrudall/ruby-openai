module OpenAI
  module Images
    def generate_images(parameters: {})
      json_post(path: "/images/generations", parameters: parameters)
    end

    def edit_image(parameters: {})
      multipart_post(path: "/images/edits", parameters: open_files(parameters))
    end

    def image_variations(parameters: {})
      multipart_post(path: "/images/variations", parameters: open_files(parameters))
    end

    private

    def open_files(parameters)
      parameters = parameters.merge(image: File.open(parameters[:image]))
      parameters = parameters.merge(mask: File.open(parameters[:mask])) if parameters[:mask]
      parameters
    end
  end
end
