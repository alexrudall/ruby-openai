module OpenAI
  module Moderations
    def embeddings(parameters: {})
      json_post(path: "/embeddings", parameters: parameters)
    end
  end
end
