module OpenAI
  module Finetunes
    def self.list
      OpenAI::Client.get(path: "/fine-tunes")
    end

    def self.create(parameters: {})
      OpenAI::Client.json_post(path: "/fine-tunes", parameters: parameters)
    end

    def self.retrieve(id:)
      OpenAI::Client.get(path: "/fine-tunes/#{id}")
    end

    def self.cancel(id:)
      OpenAI::Client.multipart_post(path: "/fine-tunes/#{id}/cancel")
    end

    def self.events(id:)
      OpenAI::Client.get(path: "/fine-tunes/#{id}/events")
    end

    def self.delete(fine_tuned_model:)
      if fine_tuned_model.start_with?("ft-")
        raise ArgumentError, "Please give a fine_tuned_model name, not a fine-tune ID"
      end

      OpenAI::Client.delete(path: "/models/#{fine_tuned_model}")
    end
  end
end
