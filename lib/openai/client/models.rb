module OpenAI
  module Models
    def models
      get("/models")
    end

    def model(id:)
      get("/models/#{id}")
    end
  end
end
