module OpenAI
  module Moderations
    def moderations(parameters: {})
      json_post("/moderations", parameters: parameters)
    end
  end
end
