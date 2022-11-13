# Ruby::OpenAI

[![Gem Version](https://badge.fury.io/rb/ruby-openai.svg)](https://badge.fury.io/rb/ruby-openai)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/alexrudall/ruby-openai/blob/main/LICENSE.txt)
[![CircleCI Build Status](https://circleci.com/gh/alexrudall/ruby-openai.svg?style=shield)](https://circleci.com/gh/alexrudall/ruby-openai)
[![Maintainability](https://api.codeclimate.com/v1/badges/a99a88d28ad37a79dbf6/maintainability)](https://codeclimate.com/github/codeclimate/codeclimate/maintainability)

Use the [OpenAI GPT-3 API](https://openai.com/blog/openai-api/) with Ruby! 🤖❤️

## Installation

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
    require "ruby/openai"
```

## Usage

Get your API key from [https://beta.openai.com/account/api-keys](https://beta.openai.com/account/api-keys)

### With dotenv

If you're using [dotenv](https://github.com/motdotla/dotenv), you can add your secret key to your .env file:

```
    OPENAI_ACCESS_TOKEN=access_token_goes_here
```

And create a client:

```ruby
    client = OpenAI::Client.new
```

### Without dotenv

Alternatively you can pass your key directly to a new client:

```ruby
    client = OpenAI::Client.new(access_token: "access_token_goes_here")
```

### Models

There are different models that can be used to generate text. For a full list and to retrieve information about a single models:

```ruby
    client.models.list
    client.models.retrieve(id: "text-ada-001")
```

#### Examples

- [GPT-3](https://beta.openai.com/docs/models/gpt-3)
  - text-ada-001
  - text-babbage-001
  - text-curie-001
  - text-davinci-001
- [Codex (private beta)](https://beta.openai.com/docs/models/codex-series-private-beta)
  - code-davinci-002
  - code-cushman-001

### Completions

Hit the OpenAI API for a completion:

```ruby
    response = client.completions(
        parameters: {
            model: "text-davinci-001",
            prompt: "Once upon a time",
            max_tokens: 5
        })
    puts response["choices"].map { |c| c["text"] }
    => [", there lived a great"]
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
    => What day of the week is it?
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
    {"text": "puppy A is happy", "metadata": "emotional state of puppy A"}
    {"text": "puppy B is sad", "metadata": "emotional state of puppy B"}
```

and pass the path to `client.files.upload` to upload it to OpenAI, and then interact with it:

```ruby
    client.files.upload(parameters: { file: "path/to/puppy.jsonl", purpose: "search" })
    client.files.list
    client.files.retrieve(id: 123)
    client.files.delete(id: 123)
```

### Fine-tunes

Put your fine-tuning data in a `.jsonl` file like this:

```json
    {"prompt":"Overjoyed with my new phone! ->", "completion":" positive"}
    {"prompt":"@lakers disappoint for a third straight night ->", "completion":" negative"}
```

and pass the path to `client.files.upload` to upload it to OpenAI and get its ID:

```ruby
    response = client.files.upload(parameters: { file: "path/to/sentiment.jsonl", purpose: "fine-tune" })
    file_id = JSON.parse(response.body)["id"]
```

You can then use this file ID to create a fine-tune model:

```ruby
    response = client.finetunes.create(
        parameters: {
        training_file: file_id,
        model: "text-ada-001"
    })
    fine_tune_id = JSON.parse(response.body)["id"]
```

That will give you the fine-tune ID. If you made a mistake you can cancel the fine-tune model before it is processed:

```ruby
    client.finetunes.cancel(id: fine_tune_id)
```

You may need to wait a short time for processing to complete. Once processed, you can use list or retrieve to get the name of the fine-tuned model:

```ruby
    client.finetunes.list
    response = client.finetunes.retrieve(id: fine_tune_id)
    fine_tuned_model = JSON.parse(response.body)["fine_tuned_model"]
```

This fine-tuned model name can then be used in classifications:

```ruby
    response = client.completions(
        parameters: {
            model: fine_tuned_model,
            prompt: "I love Mondays!"
        }
    )
    JSON.parse(response.body)["choices"].map { |c| c["text"] }
```

### Images

Generate an image using DALL·E!

```ruby
    response = client.images.generate(parameters: { prompt: "A baby sea otter cooking pasta wearing a hat of some sort" })
    puts response.dig("data", 0, "url") }
    => "https://oaidalleapiprodscus.blob.core.windows.net/private/org-Rf437IxKhh..."
```

![Otter Chef](https://oaidalleapiprodscus.blob.core.windows.net/private/org-Rf437IxKhhQPMiIQ0Es8OwrH/user-jxM65ijkZc1qRfHC0IJ8mOIc/img-UrDvFC4tDnuhTieF7TrTJ2gq.png?st=2022-11-13T15%3A55%3A34Z&se=2022-11-13T17%3A55%3A34Z&sp=r&sv=2021-08-06&sr=b&rscd=inline&rsct=image/png&skoid=6aaadede-4fb3-4698-a8f6-684d7786b067&sktid=a48cca56-e6da-484e-a814-9c849652bcb3&skt=2022-11-13T01%3A32%3A30Z&ske=2022-11-14T01%3A32%3A30Z&sks=b&skv=2021-08-06&sig=tLdggckHl20CnnpCleoeiAEQjy4zMjuZJiUdovmkoF0%3D)

### Moderations

Pass a string to check if it violates OpenAI's Content Policy:

```ruby
    response = client.moderations(parameters: { input: "I'm worried about that." })
    puts response.dig("results", 0, "category_scores", "hate")
    => 5.505014632944949e-05
```

### Classifications

Pass examples and a query to predict the most likely labels:

```ruby
    response = client.classifications(parameters: {
        examples: [
            ["A happy moment", "Positive"],
            ["I am sad.", "Negative"],
            ["I am feeling awesome", "Positive"]
        ],
        query: "It is a raining day :(",
        model: "text-ada-001"
    })
```

Or use the ID of a file you've uploaded:

```ruby
    response = client.classifications(parameters: {
        file: "123abc,
        query: "It is a raining day :(",
        model: "text-ada-001"
    })
```

### Answers

Pass documents, a question string, and an example question/response to get an answer to a question:

```ruby
    response = client.answers(parameters: {
        documents: ["Puppy A is happy.", "Puppy B is sad."],
        question: "which puppy is happy?",
        model: "text-curie-001",
        examples_context: "In 2017, U.S. life expectancy was 78.6 years.",
        examples: [["What is human life expectancy in the United States?","78 years."]],
    })
```

Or use the ID of a file you've uploaded:

```ruby
    response = client.answers(parameters: {
        file: "123abc",
        question: "which puppy is happy?",
        model: "text-curie-001",
        examples_context: "In 2017, U.S. life expectancy was 78.6 years.",
        examples: [["What is human life expectancy in the United States?","78 years."]],
    })
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, update `CHANGELOG.md`, run `bundle install` to update Gemfile.lock, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alexrudall/ruby-openai. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/alexrudall/ruby-openai/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ruby::OpenAI project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/alexrudall/ruby-openai/blob/main/CODE_OF_CONDUCT.md).
