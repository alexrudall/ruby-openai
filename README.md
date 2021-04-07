# Ruby::OpenAI

[![Gem Version](https://badge.fury.io/rb/ruby-openai.svg)](https://badge.fury.io/rb/ruby-openai)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/alexrudall/ruby-openai/blob/main/LICENSE.txt)
[![CircleCI Build Status](https://circleci.com/gh/alexrudall/ruby-openai.svg?style=shield)](https://circleci.com/gh/alexrudall/ruby-openai)

A simple Ruby wrapper for the [OpenAI GPT-3 API](https://openai.com/blog/openai-api/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby-openai'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ruby-openai

## Usage

Get your API key from [https://beta.openai.com/docs/developer-quickstart/your-api-keys](https://beta.openai.com/docs/developer-quickstart/your-api-keys)

### With dotenv

If you're using [dotenv](https://github.com/motdotla/dotenv), you can add your secret key to your .env file:

```
    OPENAI_ACCESS_TOKEN=access_token_goes_here
```

And create a client:

```
    client = OpenAI::Client.new
```

### Without dotenv

Alternatively you can pass your key directly to a new client:

```
    client = OpenAI::Client.new(access_token: "access_token_goes_here")
```

### Completions

The engine options are currently "ada", "babbage", "curie" and "davinci". Hit the OpenAI API for a completion:

```
    response = client.completions(engine: "davinci", parameters: { prompt: "Once upon a time", max_tokens: 5 })
    puts response.parsed_response['choices'].map{ |c| c["text"] }
    => [", there lived a great"]
```

### Files

Put your data in a `.jsonl` file like this:

```
    {"text": "puppy A is happy", "metadata": "emotional state of puppy A"}
    {"text": "puppy B is sad", "metadata": "emotional state of puppy B"}
```

and pass the path to `client.files.upload` to upload it to OpenAI, and then interact with it:

```
    client.files.upload(parameters: { file: 'path/to/puppy.jsonl', purpose: 'search' })
    client.files.list
    client.files.retrieve(id: 123)
    client.files.delete(id: 123)
```

### Search

Pass documents and a query string to get semantic search scores against each document:

```
    response = client.search(engine: "ada", documents: %w[washington hospital school], query: "president")
    puts response["data"].map { |d| d["score"] }
    => [202.0, 48.052, 19.247]
```

You can alternatively search using the ID of a file you've uploaded:

```
    client.search(engine: "ada", file: "abc123", query: "happy")
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alexrudall/ruby-openai. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/alexrudall/ruby-openai/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ruby::OpenAI project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/alexrudall/ruby-openai/blob/main/CODE_OF_CONDUCT.md).
