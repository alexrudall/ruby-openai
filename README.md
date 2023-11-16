# Ruby OpenAI

[![Gem Version](https://img.shields.io/gem/v/ruby-openai.svg)](https://rubygems.org/gems/ruby-openai)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/alexrudall/ruby-openai/blob/main/LICENSE.txt)
[![CircleCI Build Status](https://circleci.com/gh/alexrudall/ruby-openai.svg?style=shield)](https://circleci.com/gh/alexrudall/ruby-openai)

Use the [OpenAI API](https://openai.com/blog/openai-api/) with Ruby! 🤖❤️

Stream text with GPT-4, transcribe and translate audio with Whisper, or create images with DALL·E...

[🚢 Hire me](https://peaceterms.com?utm_source=ruby-openai&utm_medium=readme&utm_id=26072023) | [🎮 Ruby AI Builders Discord](https://discord.gg/k4Uc224xVD) | [🐦 Twitter](https://twitter.com/alexrudall) | [🧠 Anthropic Gem](https://github.com/alexrudall/anthropic) | [🚂 Midjourney Gem](https://github.com/alexrudall/midjourney)

### Bundler

Add this line to your application's Gemfile:

```ruby
gem "ruby-openai"
```

And then execute:

```bash
$ bundle install
```

### Gem install

Or install with:

```bash
$ gem install ruby-openai
```

and require with:

```ruby
require "openai"
```

## Usage

- Get your API key from [https://platform.openai.com/account/api-keys](https://platform.openai.com/account/api-keys)
- If you belong to multiple organizations, you can get your Organization ID from [https://platform.openai.com/account/org-settings](https://platform.openai.com/account/org-settings)

### Quickstart

For a quick test you can pass your token directly to a new client:

```ruby
client = OpenAI::Client.new(access_token: "access_token_goes_here")
```

### With Config

For a more robust setup, you can configure the gem with your API keys, for example in an `openai.rb` initializer file. Never hardcode secrets into your codebase - instead use something like [dotenv](https://github.com/motdotla/dotenv) to pass the keys safely into your environments.

```ruby
OpenAI.configure do |config|
    config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")
    config.organization_id = ENV.fetch("OPENAI_ORGANIZATION_ID") # Optional.
end
```

Then you can create a client like this:

```ruby
client = OpenAI::Client.new
```

You can still override the config defaults when making new clients; any options not included will fall back to any global config set with OpenAI.configure. e.g. in this example the organization_id, request_timeout, etc. will fallback to any set globally using OpenAI.configure, with only the access_token overridden:

```ruby
client = OpenAI::Client.new(access_token: "access_token_goes_here")
```

#### Custom timeout or base URI

The default timeout for any request using this library is 120 seconds. You can change that by passing a number of seconds to the `request_timeout` when initializing the client. You can also change the base URI used for all requests, eg. to use observability tools like [Helicone](https://docs.helicone.ai/quickstart/integrate-in-one-line-of-code), and add arbitrary other headers e.g. for [openai-caching-proxy-worker](https://github.com/6/openai-caching-proxy-worker):

```ruby
client = OpenAI::Client.new(
    access_token: "access_token_goes_here",
    uri_base: "https://oai.hconeai.com/",
    request_timeout: 240,
    extra_headers: {
      "X-Proxy-TTL" => "43200", # For https://github.com/6/openai-caching-proxy-worker#specifying-a-cache-ttl
      "X-Proxy-Refresh": "true", # For https://github.com/6/openai-caching-proxy-worker#refreshing-the-cache
      "Helicone-Auth": "Bearer HELICONE_API_KEY", # For https://docs.helicone.ai/getting-started/integration-method/openai-proxy
      "helicone-stream-force-format" => "true", # Use this with Helicone otherwise streaming drops chunks # https://github.com/alexrudall/ruby-openai/issues/251
    }
)
```

or when configuring the gem:

```ruby
OpenAI.configure do |config|
    config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")
    config.organization_id = ENV.fetch("OPENAI_ORGANIZATION_ID") # Optional
    config.uri_base = "https://oai.hconeai.com/" # Optional
    config.request_timeout = 240 # Optional
    config.extra_headers = {
      "X-Proxy-TTL" => "43200", # For https://github.com/6/openai-caching-proxy-worker#specifying-a-cache-ttl
      "X-Proxy-Refresh": "true", # For https://github.com/6/openai-caching-proxy-worker#refreshing-the-cache
      "Helicone-Auth": "Bearer HELICONE_API_KEY" # For https://docs.helicone.ai/getting-started/integration-method/openai-proxy
    } # Optional
end
```

#### Azure

To use the [Azure OpenAI Service](https://learn.microsoft.com/en-us/azure/cognitive-services/openai/) API, you can configure the gem like this:

```ruby
    OpenAI.configure do |config|
        config.access_token = ENV.fetch("AZURE_OPENAI_API_KEY")
        config.uri_base = ENV.fetch("AZURE_OPENAI_URI")
        config.api_type = :azure
        config.api_version = "2023-03-15-preview"
    end
```

where `AZURE_OPENAI_URI` is e.g. `https://custom-domain.openai.azure.com/openai/deployments/gpt-35-turbo`

### Counting Tokens

OpenAI parses prompt text into [tokens](https://help.openai.com/en/articles/4936856-what-are-tokens-and-how-to-count-them), which are words or portions of words. (These tokens are unrelated to your API access_token.) Counting tokens can help you estimate your [costs](https://openai.com/pricing). It can also help you ensure your prompt text size is within the max-token limits of your model's context window, and choose an appropriate [`max_tokens`](https://platform.openai.com/docs/api-reference/chat/create#chat/create-max_tokens) completion parameter so your response will fit as well.

To estimate the token-count of your text:

```ruby
OpenAI.rough_token_count("Your text")
```

If you need a more accurate count, try [tiktoken_ruby](https://github.com/IAPark/tiktoken_ruby).

### Models

There are different models that can be used to generate text. For a full list and to retrieve information about a single model:

```ruby
client.models.list
client.models.retrieve(id: "text-ada-001")
```

#### Examples

- [GPT-4 (limited beta)](https://platform.openai.com/docs/models/gpt-4)
  - gpt-4 (uses current version)
  - gpt-4-0314
  - gpt-4-32k
- [GPT-3.5](https://platform.openai.com/docs/models/gpt-3-5)
  - gpt-3.5-turbo
  - gpt-3.5-turbo-0301
  - text-davinci-003
- [GPT-3](https://platform.openai.com/docs/models/gpt-3)
  - text-ada-001
  - text-babbage-001
  - text-curie-001

### Chat

GPT is a model that can be used to generate text in a conversational style. You can use it to [generate a response](https://platform.openai.com/docs/api-reference/chat/create) to a sequence of [messages](https://platform.openai.com/docs/guides/chat/introduction):

```ruby
response = client.chat(
    parameters: {
        model: "gpt-3.5-turbo", # Required.
        messages: [{ role: "user", content: "Hello!"}], # Required.
        temperature: 0.7,
    })
puts response.dig("choices", 0, "message", "content")
# => "Hello! How may I assist you today?"
```

#### Streaming Chat

[Quick guide to streaming Chat with Rails 7 and Hotwire](https://gist.github.com/alexrudall/cb5ee1e109353ef358adb4e66631799d)

You can stream from the API in realtime, which can be much faster and used to create a more engaging user experience. Pass a [Proc](https://ruby-doc.org/core-2.6/Proc.html) (or any object with a `#call` method) to the `stream` parameter to receive the stream of completion chunks as they are generated. Each time one or more chunks is received, the proc will be called once with each chunk, parsed as a Hash. If OpenAI returns an error, `ruby-openai` will raise a Faraday error.

```ruby
client.chat(
    parameters: {
        model: "gpt-3.5-turbo", # Required.
        messages: [{ role: "user", content: "Describe a character called Anna!"}], # Required.
        temperature: 0.7,
        stream: proc do |chunk, _bytesize|
            print chunk.dig("choices", 0, "delta", "content")
        end
    })
# => "Anna is a young woman in her mid-twenties, with wavy chestnut hair that falls to her shoulders..."
```

Note: OpenAPI currently does not report token usage for streaming responses. To count tokens while streaming, try `OpenAI.rough_token_count` or [tiktoken_ruby](https://github.com/IAPark/tiktoken_ruby). We think that each call to the stream proc corresponds to a single token, so you can also try counting the number of calls to the proc to get the completion token count.

#### Vision

You can use the GPT-4 Vision model to generate a description of an image:

```ruby
messages = [
  { "type": "text", "text": "What’s in this image?"},
  { "type": "image_url",
    "image_url": {
      "url": "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg",
    },
  }
]
response = client.chat(
    parameters: {
        model: "gpt-4-vision-preview", # Required.
        messages: [{ role: "user", content: messages}], # Required.
    })
puts response.dig("choices", 0, "message", "content")
# => "The image depicts a serene natural landscape featuring a long wooden boardwalk extending straight ahead"
```

#### JSON Mode

You can set the response_format to ask for responses in JSON (at least for `gpt-3.5-turbo-1106`):

```ruby
  response = client.chat(
    parameters: {
        model: "gpt-3.5-turbo-1106",
        response_format: { type: "json_object" },
        messages: [{ role: "user", content: "Hello! Give me some JSON please."}],
        temperature: 0.7,
    })
    puts response.dig("choices", 0, "message", "content")
    {
      "name": "John",
      "age": 30,
      "city": "New York",
      "hobbies": ["reading", "traveling", "hiking"],
      "isStudent": false
    }
```

You can stream it as well!

```ruby
  response = client.chat(
    parameters: {
      model: "gpt-3.5-turbo-1106",
      messages: [{ role: "user", content: "Can I have some JSON please?"}],
        response_format: { type: "json_object" },
        stream: proc do |chunk, _bytesize|
          print chunk.dig("choices", 0, "delta", "content")
        end
  })
  {
    "message": "Sure, please let me know what specific JSON data you are looking for.",
    "JSON_data": {
      "example_1": {
        "key_1": "value_1",
        "key_2": "value_2",
        "key_3": "value_3"
      },
      "example_2": {
        "key_4": "value_4",
        "key_5": "value_5",
        "key_6": "value_6"
      }
    }
  }
```

### Functions

You can describe and pass in functions and the model will intelligently choose to output a JSON object containing arguments to call those them. For example, if you want the model to use your method `get_current_weather` to get the current weather in a given location:

```ruby
def get_current_weather(location:, unit: "fahrenheit")
  # use a weather api to fetch weather
end

response =
  client.chat(
    parameters: {
      model: "gpt-3.5-turbo-0613",
      messages: [
        {
          "role": "user",
          "content": "What is the weather like in San Francisco?",
        },
      ],
      functions: [
        {
          name: "get_current_weather",
          description: "Get the current weather in a given location",
          parameters: {
            type: :object,
            properties: {
              location: {
                type: :string,
                description: "The city and state, e.g. San Francisco, CA",
              },
              unit: {
                type: "string",
                enum: %w[celsius fahrenheit],
              },
            },
            required: ["location"],
          },
        },
      ],
    },
  )

message = response.dig("choices", 0, "message")

if message["role"] == "assistant" && message["function_call"]
  function_name = message.dig("function_call", "name")
  args =
    JSON.parse(
      message.dig("function_call", "arguments"),
      { symbolize_names: true },
    )

  case function_name
  when "get_current_weather"
    get_current_weather(**args)
  end
end
# => "The weather is nice 🌞"
```

### Edits

Send a string and some instructions for what to do to the string:

```ruby
response = client.edits(
    parameters: {
        model: "text-davinci-edit-001",
        input: "What day of the wek is it?",
        instruction: "Fix the spelling mistakes"
    }
)
puts response.dig("choices", 0, "text")
# => What day of the week is it?
```

### Embeddings

You can use the embeddings endpoint to get a vector of numbers representing an input. You can then compare these vectors for different inputs to efficiently check how similar the inputs are.

```ruby
response = client.embeddings(
    parameters: {
        model: "text-embedding-ada-002",
        input: "The food was delicious and the waiter..."
    }
)

puts response.dig("data", 0, "embedding")
# => Vector representation of your embedding
```

### Files

Put your data in a `.jsonl` file like this:

```json
{"prompt":"Overjoyed with my new phone! ->", "completion":" positive"}
{"prompt":"@lakers disappoint for a third straight night ->", "completion":" negative"}
```

and pass the path to `client.files.upload` to upload it to OpenAI, and then interact with it:

```ruby
client.files.upload(parameters: { file: "path/to/sentiment.jsonl", purpose: "fine-tune" })
client.files.list
client.files.retrieve(id: "file-123")
client.files.content(id: "file-123")
client.files.delete(id: "file-123")
```

### Finetunes

Upload your fine-tuning data in a `.jsonl` file as above and get its ID:

```ruby
response = client.files.upload(parameters: { file: "path/to/sarcasm.jsonl", purpose: "fine-tune" })
file_id = JSON.parse(response.body)["id"]
```

You can then use this file ID to create a fine tuning job:

```ruby
response = client.finetunes.create(
    parameters: {
    training_file: file_id,
    model: "gpt-3.5-turbo-0613"
})
fine_tune_id = response["id"]
```

That will give you the fine-tune ID. If you made a mistake you can cancel the fine-tune model before it is processed:

```ruby
client.finetunes.cancel(id: fine_tune_id)
```

You may need to wait a short time for processing to complete. Once processed, you can use list or retrieve to get the name of the fine-tuned model:

```ruby
client.finetunes.list
response = client.finetunes.retrieve(id: fine_tune_id)
fine_tuned_model = response["fine_tuned_model"]
```

This fine-tuned model name can then be used in completions:

```ruby
response = client.completions(
    parameters: {
        model: fine_tuned_model,
        prompt: "I love Mondays!"
    }
)
response.dig("choices", 0, "text")
```

You can also capture the events for a job:

```
client.finetunes.list_events(id: fine_tune_id)
```

### Image Generation

Generate an image using DALL·E! The size of any generated images must be one of `256x256`, `512x512` or `1024x1024` -
if not specified the image will default to `1024x1024`.

```ruby
response = client.images.generate(parameters: { prompt: "A baby sea otter cooking pasta wearing a hat of some sort", size: "256x256" })
puts response.dig("data", 0, "url")
# => "https://oaidalleapiprodscus.blob.core.windows.net/private/org-Rf437IxKhh..."
```

![Ruby](https://i.ibb.co/6y4HJFx/img-d-Tx-Rf-RHj-SO5-Gho-Cbd8o-LJvw3.png)

### Image Edit

Fill in the transparent part of an image, or upload a mask with transparent sections to indicate the parts of an image that can be changed according to your prompt...

```ruby
response = client.images.edit(parameters: { prompt: "A solid red Ruby on a blue background", image: "image.png", mask: "mask.png" })
puts response.dig("data", 0, "url")
# => "https://oaidalleapiprodscus.blob.core.windows.net/private/org-Rf437IxKhh..."
```

![Ruby](https://i.ibb.co/sWVh3BX/dalle-ruby.png)

### Image Variations

Create n variations of an image.

```ruby
response = client.images.variations(parameters: { image: "image.png", n: 2 })
puts response.dig("data", 0, "url")
# => "https://oaidalleapiprodscus.blob.core.windows.net/private/org-Rf437IxKhh..."
```

![Ruby](https://i.ibb.co/TWJLP2y/img-miu-Wk-Nl0-QNy-Xtj-Lerc3c0l-NW.png)
![Ruby](https://i.ibb.co/ScBhDGB/img-a9-Be-Rz-Au-Xwd-AV0-ERLUTSTGdi.png)

### Moderations

Pass a string to check if it violates OpenAI's Content Policy:

```ruby
response = client.moderations(parameters: { input: "I'm worried about that." })
puts response.dig("results", 0, "category_scores", "hate")
# => 5.505014632944949e-05
```

### Whisper

Whisper is a speech to text model that can be used to generate text based on audio files:

#### Translate

The translations API takes as input the audio file in any of the supported languages and transcribes the audio into English.

```ruby
response = client.audio.translate(
    parameters: {
        model: "whisper-1",
        file: File.open("path_to_file", "rb"),
    })
puts response["text"]
# => "Translation of the text"
```

#### Transcribe

The transcriptions API takes as input the audio file you want to transcribe and returns the text in the desired output file format.

```ruby
response = client.audio.transcribe(
    parameters: {
        model: "whisper-1",
        file: File.open("path_to_file", "rb"),
    })
puts response["text"]
# => "Transcription of the text"
```

#### Speech

The speech API takes as input the text and a voice and returns the content of an audio file you can listen to.

```ruby
response = client.audio.speech(
  parameters: {
    model: "tts-1",
    input: "This is a speech test!",
    voice: "alloy"
  }
)
File.binwrite('demo.mp3', response)
# => mp3 file that plays: "This is a speech test!"
```

### Errors

HTTP errors can be caught like this:

```
  begin
    OpenAI::Client.new.models.retrieve(id: "text-ada-001")
  rescue Faraday::Error => e
    raise "Got a Faraday error: #{e}"
  end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

### Warning

If you have an `OPENAI_ACCESS_TOKEN` in your `ENV`, running the specs will use this to run the specs against the actual API, which will be slow and cost you money - 2 cents or more! Remove it from your environment with `unset` or similar if you just want to run the specs against the stored VCR responses.

## Release

First run the specs without VCR so they actually hit the API. This will cost 2 cents or more. Set OPENAI_ACCESS_TOKEN in your environment or pass it in like this:

```
OPENAI_ACCESS_TOKEN=123abc bundle exec rspec
```

Then update the version number in `version.rb`, update `CHANGELOG.md`, run `bundle install` to update Gemfile.lock, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/alexrudall/ruby-openai>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/alexrudall/ruby-openai/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ruby OpenAI project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/alexrudall/ruby-openai/blob/main/CODE_OF_CONDUCT.md).
