module OpenAI
  module Edits
    def edits(parameters: {})
      json_post("/edits", parameters: parameters)
    end
  end
end
