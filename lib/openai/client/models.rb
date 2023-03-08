module OpenAI
  module Models
    def models
      get(path: "/models")
    end

    def model(id:)
      get(path: "/models/#{id}")
    end
  end
end
