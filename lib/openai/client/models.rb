module OpenAI
  module Models
    def models
      OpenAI::Client.get(path: "/models")
    end

    def model(id:)
      OpenAI::Client.get(path: "/models/#{id}")
    end
  end
end
