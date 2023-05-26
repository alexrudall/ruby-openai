# Ruby OpenAI

[![Gem Version](https://badge.fury.io/rb/ruby-openai.svg)](https://badge.fury.io/rb/ruby-openai)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/alexrudall/ruby-openai/blob/main/LICENSE.txt)
[![CircleCI Build Status](https://circleci.com/gh/alexrudall/ruby-openai.svg?style=shield)](https://circleci.com/gh/alexrudall/ruby-openai)

Use the [OpenAI API](https://openai.com/blog/openai-api/) with Ruby! 🤖❤️

Stream text with GPT-4, transcribe and translate audio with Whisper, or create images with DALL·E...

[Ruby AI Builders Discord](https://discord.gg/k4Uc224xVD)

[Quick guide to streaming ChatGPT with Rails 7 and Hotwire](https://gist.github.com/alexrudall/cb5ee1e109353ef358adb4e66631799d)

Follow me on [Twitter](https://twitter.com/alexrudall) for more Ruby / AI content

### Bundler

Add this line to your application's Gemfile:

```ruby
gem "ruby-openai"
```

And then execute:

$ bundle install

### Gem install

Or install with:

$ gem install ruby-openai

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

#### Custom timeout or base URI

The default timeout for any request using this library is 120 seconds. You can change that by passing a number of seconds to the `request_timeout` when initializing the client. You can also change the base URI used for all requests, eg. to use observability tools like [Helicone](https://docs.helicone.ai/quickstart/integrate-in-one-line-of-code):

```ruby
client = OpenAI::Client.new(
    access_token: "access_token_goes_here",
    uri_base: "https://oai.hconeai.com/",
    request_timeout: 240
)
```

or when configuring the gem:

```ruby
OpenAI.configure do |config|
    config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")
    config.organization_id = ENV.fetch("OPENAI_ORGANIZATION_ID") # Optional
    config.uri_base = "https://oai.hconeai.com/" # Optional
    config.request_timeout = 240 # Optional
end
```

### Models

There are different models that can be used to generate text. For a full list and to retrieve information about a single model:

```ruby
client.models.list
client.models.retrieve(id: "text-ada-001")
```

#### Examples

- [GPT-4 (limited beta)](https://platform.openai.com/docs/models/gpt-4)
  - gpt-4
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

### ChatGPT

ChatGPT is a model that can be used to generate text in a conversational style. You can use it to [generate a response](https://platform.openai.com/docs/api-reference/chat/create) to a sequence of [messages](https://platform.openai.com/docs/guides/chat/introduction):

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

### Streaming ChatGPT

[Quick guide to streaming ChatGPT with Rails 7 and Hotwire](https://gist.github.com/alexrudall/cb5ee1e109353ef358adb4e66631799d)

You can stream from the API in realtime, which can be much faster and used to create a more engaging user experience. Pass a [Proc](https://ruby-doc.org/core-2.6/Proc.html) (or any object with a `#call` method) to the `stream` parameter to receive the stream of text chunks as they are generated. Each time one or more chunks is received, the proc will be called once with each chunk, parsed as a Hash. If OpenAI returns an error, `ruby-openai` will pass that to your proc as a Hash.

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

### Completions

Hit the OpenAI API for a completion using other GPT-3 models:

```ruby
response = client.completions(
    parameters: {
        model: "text-davinci-001",
        prompt: "Once upon a time",
        max_tokens: 5
    })
puts response["choices"].map { |c| c["text"] }
# => [", there lived a great"]
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
client.embeddings(
    parameters: {
        model: "babbage-similarity",
        input: "The food was delicious and the waiter..."
    }
)
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

### Fine-tunes

Upload your fine-tuning data in a `.jsonl` file as above and get its ID:

```ruby
response = client.files.upload(parameters: { file: "path/to/sentiment.jsonl", purpose: "fine-tune" })
file_id = JSON.parse(response.body)["id"]
```

You can then use this file ID to create a fine-tune model:

```ruby
response = client.finetunes.create(
    parameters: {
    training_file: file_id,
    model: "ada"
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

You can delete the fine-tuned model when you are done with it:

```ruby
client.finetunes.delete(fine_tuned_model: fine_tuned_model)
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
response = client.translate(
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
response = client.transcribe(
    parameters: {
        model: "whisper-1",
        file: File.open("path_to_file", "rb"),
    })
puts response["text"]
# => "Transcription of the text"
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
