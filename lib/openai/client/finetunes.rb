module OpenAI
  module Finetunes
    def finetunes
      get(path: "/fine-tunes")
    end

    def create_finetunes(parameters: {})
      json_post(path: "/fine-tunes", parameters: parameters)
    end

    def finetune(id:)
      get(path: "/fine-tunes/#{id}")
    end

    def cancel_finetune(id:)
      multipart_post(path: "/fine-tunes/#{id}/cancel")
    end

    def events(id:)
      get(path: "/fine-tunes/#{id}/events")
    end

    def delete_finetune(fine_tuned_model:)
      if fine_tuned_model.start_with?("ft-")
        raise ArgumentError, "Please give a fine_tuned_model name, not a fine-tune ID"
      end

      delete(path: "/models/#{fine_tuned_model}")
    end
  end
end
