module OpenAI
  module Edits
    def edits(parameters: {})
      json_post(path: "/edits", parameters: parameters)
    end
  end
end
