module OpenAI
  module Moderations
    def embeddings(parameters: {})
      OpenAI::Client.json_post(path: "/embeddings", parameters: parameters)
    end
  end
end
