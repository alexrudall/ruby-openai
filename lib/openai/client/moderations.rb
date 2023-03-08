module OpenAI
  module Moderations
    def moderations(parameters: {})
      json_post(path: "/moderations", parameters: parameters)
    end
  end
end
