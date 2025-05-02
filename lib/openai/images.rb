module OpenAI
  class Images
    def initialize(client: nil)
      @client = client
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
      params = parameters.dup

      if params[:image].is_a?(Array)
        process_image_array(params)
      else
        params[:image] = File.open(params[:image])
      end

      params[:mask] = File.open(params[:mask]) if params[:mask]
      params
    end

    def process_image_array(params)
      params[:image].each_with_index do |img_path, index|
        params[:"image[#{index}]"] = File.open(img_path)
      end
      params.delete(:image)
    end
  end
end
