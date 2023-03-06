module OpenAI
  module Models
    def self.list
      OpenAI::Client.get(path: "/models")
    end

    def self.retrieve(id:)
      OpenAI::Client.get(path: "/models/#{id}")
    end
  end
end
