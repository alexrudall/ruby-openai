# frozen_string_literal: true
require 'ruby/openai'
class ChatGptReflex < ApplicationReflex
  def answer
    client = OpenAI::Client.new(access_token: ENV.fetch('GPT_KEY', nil))
    response = client.completions(
      parameters: {
        model: 'text-davinci-001',
        prompt: element.value,
        max_tokens: 5
      }
    )
    morph '#gpt_answer', JSON.parse(response.body)['choices'].pluck('text').to_sentence
  end
end
