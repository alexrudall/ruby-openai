module OpenAI
  module Moderations
    def embeddings(parameters: {})
      json_post("/embeddings", parameters: parameters)
    end
  end
end
