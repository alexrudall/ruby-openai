module OpenAI
  module Finetunes
    def finetunes
      get("/fine-tunes")
    end

    def create_finetunes(parameters: {})
      json_post("/fine-tunes", parameters: parameters)
    end

    def finetune(id:)
      get("/fine-tunes/#{id}")
    end

    def cancel_finetune(id:)
      multipart_post("/fine-tunes/#{id}/cancel")
    end

    def events(id:)
      get("/fine-tunes/#{id}/events")
    end

    def delete_finetune(fine_tuned_model:)
      if fine_tuned_model.start_with?("ft-")
        raise ArgumentError, "Please give a fine_tuned_model name, not a fine-tune ID"
      end

      delete("/models/#{fine_tuned_model}")
    end
  end
end
