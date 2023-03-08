module OpenAI
  module Completions
    def chat_completions(parameters: {})
      json_post(path: "/chat/completions", parameters: parameters)
    end

    def completions(parameters: {})
      json_post(path: "/completions", parameters: parameters)
    end
  end
end
