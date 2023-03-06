module OpenAI
  module Moderations
    def moderations(parameters: {})
      OpenAI::Client.json_post(path: "/moderations", parameters: parameters)
    end
  end
end
