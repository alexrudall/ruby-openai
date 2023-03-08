module OpenAI
  module Completions
    def chat_completions(parameters: {})
      json_post("/chat/completions", parameters: parameters)
    end

    def completions(parameters: {})
      json_post("/completions", parameters: parameters)
    end
  end
end
