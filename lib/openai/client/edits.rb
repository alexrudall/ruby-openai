module OpenAI
  module Edits
    def edits(parameters: {})
      OpenAI::Client.json_post(path: "/edits", parameters: parameters)
    end
  end
end
