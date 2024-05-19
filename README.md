# Ruby OpenAI

[![Gem Version](https://img.shields.io/gem/v/ruby-openai.svg)](https://rubygems.org/gems/ruby-openai)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/alexrudall/ruby-openai/blob/main/LICENSE.txt)
[![CircleCI Build Status](https://circleci.com/gh/alexrudall/ruby-openai.svg?style=shield)](https://circleci.com/gh/alexrudall/ruby-openai)

Use the [OpenAI API](https://openai.com/blog/openai-api/) with Ruby! 🤖❤️

Stream text with GPT-4o, transcribe and translate audio with Whisper, or create images with DALL·E...

[🚢 Hire me](https://peaceterms.com?utm_source=ruby-openai&utm_medium=readme&utm_id=26072023) | [🎮 Ruby AI Builders Discord](https://discord.gg/k4Uc224xVD) | [🐦 Twitter](https://twitter.com/alexrudall) | [🧠 Anthropic Gem](https://github.com/alexrudall/anthropic) | [🚂 Midjourney Gem](https://github.com/alexrudall/midjourney)

## Contents

- [Ruby OpenAI](#ruby-openai)
- [Table of Contents](#table-of-contents)
  - [Installation](#installation)
    - [Bundler](#bundler)
    - [Gem install](#gem-install)
  - [Usage](#usage)
    - [Quickstart](#quickstart)
    - [With Config](#with-config)
      - [Custom timeout or base URI](#custom-timeout-or-base-uri)
      - [Extra Headers per Client](#extra-headers-per-client)
      - [Logging](#logging)
        - [Errors](#errors)
        - [Faraday middleware](#faraday-middleware)
      - [Azure](#azure)
      - [Ollama](#ollama)
      - [Groq](#groq)
    - [Counting Tokens](#counting-tokens)
    - [Models](#models)
    - [Chat](#chat)
      - [Streaming Chat](#streaming-chat)
      - [Vision](#vision)
      - [JSON Mode](#json-mode)
    - [Functions](#functions)
    - [Completions](#completions)
    - [Embeddings](#embeddings)
    - [Batches](#batches)
    - [Files](#files)
    - [Finetunes](#finetunes)
    - [Assistants](#assistants)
    - [Threads and Messages](#threads-and-messages)
    - [Runs](#runs)
      - [Create and Run](#create-and-run)
      - [Runs involving function tools](#runs-involving-function-tools)
    - [Image Generation](#image-generation)
      - [DALL·E 2](#dalle-2)
      - [DALL·E 3](#dalle-3)
    - [Image Edit](#image-edit)
    - [Image Variations](#image-variations)
    - [Moderations](#moderations)
    - [Whisper](#whisper)
      - [Translate](#translate)
      - [Transcribe](#transcribe)
      - [Speech](#speech)
    - [Errors](#errors-1)
  - [Development](#development)
  - [Release](#release)
  - [Contributing](#contributing)
  - [License](#license)
  - [Code of Conduct](#code-of-conduct)

## Installation

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
client = OpenAI::Client.new(
  access_token: "access_token_goes_here",
  log_errors: true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production because it could leak private data to your logs.
)
```

### With Config

For a more robust setup, you can configure the gem with your API keys, for example in an `openai.rb` initializer file. Never hardcode secrets into your codebase - instead use something like [dotenv](https://github.com/motdotla/dotenv) to pass the keys safely into your environments.

```ruby
OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")
  config.organization_id = ENV.fetch("OPENAI_ORGANIZATION_ID") # Optional
  config.log_errors = true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production because it could leak private data to your logs.
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
    config.log_errors = true # Optional
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

#### Extra Headers per Client

You can dynamically pass headers per client object, which will be merged with any headers set globally with OpenAI.configure:

```ruby
client = OpenAI::Client.new(access_token: "access_token_goes_here")
client.add_headers("X-Proxy-TTL" => "43200")
```

#### Logging

##### Errors

By default, `ruby-openai` does not log any `Faraday::Error`s encountered while executing a network request to avoid leaking data (e.g. 400s, 500s, SSL errors and more - see [here](https://www.rubydoc.info/github/lostisland/faraday/Faraday/Error) for a complete list of subclasses of `Faraday::Error` and what can cause them).

If you would like to enable this functionality, you can set `log_errors` to `true` when configuring the client:

```ruby
  client = OpenAI::Client.new(log_errors: true)
```

##### Faraday middleware

You can pass [Faraday middleware](https://lostisland.github.io/faraday/#/middleware/index) to the client in a block, eg. to enable verbose logging with Ruby's [Logger](https://ruby-doc.org/3.2.2/stdlibs/logger/Logger.html):

```ruby
  client = OpenAI::Client.new do |f|
    f.response :logger, Logger.new($stdout), bodies: true
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

#### Ollama

Ollama allows you to run open-source LLMs, such as Llama 3, locally. It [offers chat compatibility](https://github.com/ollama/ollama/blob/main/docs/openai.md) with the OpenAI API.

You can download Ollama [here](https://ollama.com/). On macOS you can install and run Ollama like this:

```bash
brew install ollama
ollama serve
ollama pull llama3:latest # In new terminal tab.
```

Create a client using your Ollama server and the pulled model, and stream a conversation for free:

```ruby
client = OpenAI::Client.new(
  uri_base: "http://localhost:11434"
)

client.chat(
    parameters: {
        model: "llama3", # Required.
        messages: [{ role: "user", content: "Hello!"}], # Required.
        temperature: 0.7,
        stream: proc do |chunk, _bytesize|
            print chunk.dig("choices", 0, "delta", "content")
        end
    })

# => Hi! It's nice to meet you. Is there something I can help you with, or would you like to chat?
```

#### Groq

[Groq API Chat](https://console.groq.com/docs/quickstart) is broadly compatible with the OpenAI API, with a [few minor differences](https://console.groq.com/docs/openai). Get an access token from [here](https://console.groq.com/keys), then:

```ruby
  client = OpenAI::Client.new(
    access_token: "groq_access_token_goes_here",
    uri_base: "https://api.groq.com/openai"
  )

  client.chat(
    parameters: {
        model: "llama3-8b-8192", # Required.
        messages: [{ role: "user", content: "Hello!"}], # Required.
        temperature: 0.7,
        stream: proc do |chunk, _bytesize|
            print chunk.dig("choices", 0, "delta", "content")
        end
    })
```

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
client.models.retrieve(id: "gpt-4o")
```

### Chat

GPT is a model that can be used to generate text in a conversational style. You can use it to [generate a response](https://platform.openai.com/docs/api-reference/chat/create) to a sequence of [messages](https://platform.openai.com/docs/guides/chat/introduction):

```ruby
response = client.chat(
    parameters: {
        model: "gpt-4o", # Required.
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
        model: "gpt-4o", # Required.
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

You can set the response_format to ask for responses in JSON:

```ruby
  response = client.chat(
    parameters: {
        model: "gpt-4o",
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
      model: "gpt-4o",
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

You can describe and pass in functions and the model will intelligently choose to output a JSON object containing arguments to call them - eg., to use your method `get_current_weather` to get the weather in a given location. Note that tool_choice is optional, but if you exclude it, the model will choose whether to use the function or not ([see here](https://platform.openai.com/docs/api-reference/chat/create#chat-create-tool_choice)).

```ruby

def get_current_weather(location:, unit: "fahrenheit")
  # use a weather api to fetch weather
end

response =
  client.chat(
    parameters: {
      model: "gpt-4o",
      messages: [
        {
          "role": "user",
          "content": "What is the weather like in San Francisco?",
        },
      ],
      tools: [
        {
          type: "function",
          function: {
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
        }
      ],
      tool_choice: {
        type: "function",
        function: {
          name: "get_current_weather"
        }
      }
    },
  )

message = response.dig("choices", 0, "message")

if message["role"] == "assistant" && message["tool_calls"]
  function_name = message.dig("tool_calls", 0, "function", "name")
  args =
    JSON.parse(
      message.dig("tool_calls", 0, "function", "arguments"),
      { symbolize_names: true },
    )

  case function_name
  when "get_current_weather"
    get_current_weather(**args)
  end
end
# => "The weather is nice 🌞"
```

### Completions

Hit the OpenAI API for a completion using other GPT-3 models:

```ruby
response = client.completions(
    parameters: {
        model: "gpt-4o",
        prompt: "Once upon a time",
        max_tokens: 5
    })
puts response["choices"].map { |c| c["text"] }
# => [", there lived a great"]
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

### Batches

The Batches endpoint allows you to create and manage large batches of API requests to run asynchronously. Currently, only the `/v1/chat/completions` endpoint is supported for batches.

To use the Batches endpoint, you need to first upload a JSONL file containing the batch requests using the Files endpoint. The file must be uploaded with the purpose set to `batch`. Each line in the JSONL file represents a single request and should have the following format:

```json
{
  "custom_id": "request-1",
  "method": "POST",
  "url": "/v1/chat/completions",
  "body": {
    "model": "gpt-4o",
    "messages": [
      { "role": "system", "content": "You are a helpful assistant." },
      { "role": "user", "content": "What is 2+2?" }
    ]
  }
}
```

Once you have uploaded the JSONL file, you can create a new batch by providing the file ID, endpoint, and completion window:

```ruby
response = client.batches.create(
  parameters: {
    input_file_id: "file-abc123",
    endpoint: "/v1/chat/completions",
    completion_window: "24h"
  }
)
batch_id = response["id"]
```

You can retrieve information about a specific batch using its ID:

```ruby
batch = client.batches.retrieve(id: batch_id)
```

To cancel a batch that is in progress:

```ruby
client.batches.cancel(id: batch_id)
```

You can also list all the batches:

```ruby
client.batches.list
```

Once the batch["completed_at"] is present, you can fetch the output or error files:

```ruby
batch = client.batches.retrieve(id: batch_id)
output_file_id = batch["output_file_id"]
output_response = client.files.content(id: output_file_id)
error_file_id = batch["error_file_id"]
error_response = client.files.content(id: error_file_id)
```

These files are in JSONL format, with each line representing the output or error for a single request. The lines can be in any order:

```json
{
  "id": "response-1",
  "custom_id": "request-1",
  "response": {
    "id": "chatcmpl-abc123",
    "object": "chat.completion",
    "created": 1677858242,
    "model": "gpt-4o",
    "choices": [
      {
        "index": 0,
        "message": {
          "role": "assistant",
          "content": "2+2 equals 4."
        }
      }
    ]
  }
}
```

If a request fails with a non-HTTP error, the error object will contain more information about the cause of the failure.

### Files

Put your data in a `.jsonl` file like this:

```json
{"prompt":"Overjoyed with my new phone! ->", "completion":" positive"}
{"prompt":"@lakers disappoint for a third straight night ->", "completion":" negative"}
```

and pass the path (or a StringIO object) to `client.files.upload` to upload it to OpenAI, and then interact with it:

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
    model: "gpt-4o"
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

This fine-tuned model name can then be used in chat completions:

```ruby
response = client.chat(
    parameters: {
        model: fine_tuned_model,
        messages: [{ role: "user", content: "I love Mondays!"}]
    }
)
response.dig("choices", 0, "message", "content")
```

You can also capture the events for a job:

```
client.finetunes.list_events(id: fine_tune_id)
```

### Assistants

Assistants are stateful actors that can have many conversations and use tools to perform tasks (see [Assistant Overview](https://platform.openai.com/docs/assistants/overview)).

To create a new assistant:

```ruby
response = client.assistants.create(
    parameters: {
        model: "gpt-4o",
        name: "OpenAI-Ruby test assistant",
        description: nil,
        instructions: "You are a Ruby dev bot. When asked a question, write and run Ruby code to answer the question",
        tools: [
            { type: "code_interpreter" },
        ],
        tool_resources: {
          "code_interpreter": {
            "file_ids": [] # See Files section above for how to upload files
          }
        },
        "metadata": { my_internal_version_id: "1.0.0" }
    })
assistant_id = response["id"]
```

Given an `assistant_id` you can `retrieve` the current field values:

```ruby
client.assistants.retrieve(id: assistant_id)
```

You can get a `list` of all assistants currently available under the organization:

```ruby
client.assistants.list
```

You can modify an existing assistant using the assistant's id (see [API documentation](https://platform.openai.com/docs/api-reference/assistants/modifyAssistant)):

```ruby
response = client.assistants.modify(
        id: assistant_id,
        parameters: {
            name: "Modified Test Assistant for OpenAI-Ruby",
            metadata: { my_internal_version_id: '1.0.1' }
        })
```

You can delete assistants:

```
client.assistants.delete(id: assistant_id)
```

### Threads and Messages

Once you have created an assistant as described above, you need to prepare a `Thread` of `Messages` for the assistant to work on (see [introduction on Assistants](https://platform.openai.com/docs/assistants/how-it-works)). For example, as an initial setup you could do:

```ruby
# Create thread
response = client.threads.create # Note: Once you create a thread, there is no way to list it
                                 # or recover it currently (as of 2023-12-10). So hold onto the `id`
thread_id = response["id"]

# Add initial message from user (see https://platform.openai.com/docs/api-reference/messages/createMessage)
message_id = client.messages.create(
    thread_id: thread_id,
    parameters: {
        role: "user", # Required for manually created messages
        content: "Can you help me write an API library to interact with the OpenAI API please?"
    })["id"]

# Retrieve individual message
message = client.messages.retrieve(thread_id: thread_id, id: message_id)

# Review all messages on the thread
messages = client.messages.list(thread_id: thread_id)
```

To clean up after a thread is no longer needed:

```ruby
# To delete the thread (and all associated messages):
client.threads.delete(id: thread_id)

client.messages.retrieve(thread_id: thread_id, id: message_id) # -> Fails after thread is deleted
```

### Runs

To submit a thread to be evaluated with the model of an assistant, create a `Run` as follows:

```ruby
# Create run (will use instruction/model/tools from Assistant's definition)
response = client.runs.create(thread_id: thread_id,
    parameters: {
        assistant_id: assistant_id,
        max_prompt_tokens: 256,
        max_completion_tokens: 16
    })
run_id = response['id']
```

You can stream the message chunks as they come through:

```ruby
client.runs.create(thread_id: thread_id,
    parameters: {
        assistant_id: assistant_id,
        max_prompt_tokens: 256,
        max_completion_tokens: 16,
        stream: proc do |chunk, _bytesize|
          print chunk.dig("delta", "content", 0, "text", "value") if chunk["object"] == "thread.message.delta"
        end
    })
```

To get the status of a Run:

```
response = client.runs.retrieve(id: run_id, thread_id: thread_id)
status = response['status']
```

The `status` response can include the following strings `queued`, `in_progress`, `requires_action`, `cancelling`, `cancelled`, `failed`, `completed`, or `expired` which you can handle as follows:

```ruby
while true do
    response = client.runs.retrieve(id: run_id, thread_id: thread_id)
    status = response['status']

    case status
    when 'queued', 'in_progress', 'cancelling'
      puts 'Sleeping'
      sleep 1 # Wait one second and poll again
    when 'completed'
      break # Exit loop and report result to user
    when 'requires_action'
      # Handle tool calls (see below)
    when 'cancelled', 'failed', 'expired'
      puts response['last_error'].inspect
      break # or `exit`
    else
      puts "Unknown status response: #{status}"
    end
end
```

If the `status` response indicates that the `run` is `completed`, the associated `thread` will have one or more new `messages` attached:

```ruby
# Either retrieve all messages in bulk again, or...
messages = client.messages.list(thread_id: thread_id, parameters: { order: 'asc' })

# Alternatively retrieve the `run steps` for the run which link to the messages:
run_steps = client.run_steps.list(thread_id: thread_id, run_id: run_id, parameters: { order: 'asc' })
new_message_ids = run_steps['data'].filter_map { |step|
  if step['type'] == 'message_creation'
    step.dig('step_details', "message_creation", "message_id")
  end # Ignore tool calls, because they don't create new messages.
}

# Retrieve the individual messages
new_messages = new_message_ids.map { |msg_id|
  client.messages.retrieve(id: msg_id, thread_id: thread_id)
}

# Find the actual response text in the content array of the messages
new_messages.each { |msg|
    msg['content'].each { |content_item|
        case content_item['type']
        when 'text'
            puts content_item.dig('text', 'value')
            # Also handle annotations
        when 'image_file'
            # Use File endpoint to retrieve file contents via id
            id = content_item.dig('image_file', 'file_id')
        end
    }
}
```

You can also update the metadata on messages, including messages that come from the assistant.

```ruby
metadata = {
  user_id: "abc123"
}
message = client.messages.modify(id: message_id, thread_id: thread_id, parameters: { metadata: metadata })
```

At any time you can list all runs which have been performed on a particular thread or are currently running:

```ruby
client.runs.list(thread_id: thread_id, parameters: { order: "asc", limit: 3 })
```

#### Create and Run

You can also create a thread and run in one call like this:

```ruby
response = client.runs.create_thread_and_run(parameters: { assistant_id: assistant_id })
run_id = response['id']
thread_id = response['thread_id']
```

#### Runs involving function tools

In case you are allowing the assistant to access `function` tools (they are defined in the same way as functions during chat completion), you might get a status code of `requires_action` when the assistant wants you to evaluate one or more function tools:

```ruby
def get_current_weather(location:, unit: "celsius")
    # Your function code goes here
    if location =~ /San Francisco/i
        return unit == "celsius" ? "The weather is nice 🌞 at 27°C" : "The weather is nice 🌞 at 80°F"
    else
        return unit == "celsius" ? "The weather is icy 🥶 at -5°C" : "The weather is icy 🥶 at 23°F"
    end
end

if status == 'requires_action'

    tools_to_call = response.dig('required_action', 'submit_tool_outputs', 'tool_calls')

    my_tool_outputs = tools_to_call.map { |tool|
        # Call the functions based on the tool's name
        function_name = tool.dig('function', 'name')
        arguments = JSON.parse(
              tool.dig("function", "arguments"),
              { symbolize_names: true },
        )

        tool_output = case function_name
        when "get_current_weather"
            get_current_weather(**arguments)
        end

        { tool_call_id: tool['id'], output: tool_output }
    }

    client.runs.submit_tool_outputs(thread_id: thread_id, run_id: run_id, parameters: { tool_outputs: my_tool_outputs })
end
```

Note that you have 10 minutes to submit your tool output before the run expires.

### Image Generation

Generate images using DALL·E 2 or DALL·E 3!

#### DALL·E 2

For DALL·E 2 the size of any generated images must be one of `256x256`, `512x512` or `1024x1024` - if not specified the image will default to `1024x1024`.

```ruby
response = client.images.generate(parameters: { prompt: "A baby sea otter cooking pasta wearing a hat of some sort", size: "256x256" })
puts response.dig("data", 0, "url")
# => "https://oaidalleapiprodscus.blob.core.windows.net/private/org-Rf437IxKhh..."
```

![Ruby](https://i.ibb.co/6y4HJFx/img-d-Tx-Rf-RHj-SO5-Gho-Cbd8o-LJvw3.png)

#### DALL·E 3

For DALL·E 3 the size of any generated images must be one of `1024x1024`, `1024x1792` or `1792x1024`. Additionally the quality of the image can be specified to either `standard` or `hd`.

```ruby
response = client.images.generate(parameters: { prompt: "A springer spaniel cooking pasta wearing a hat of some sort", model: "dall-e-3", size: "1024x1792", quality: "standard" })
puts response.dig("data", 0, "url")
# => "https://oaidalleapiprodscus.blob.core.windows.net/private/org-Rf437IxKhh..."
```

![Ruby](https://i.ibb.co/z2tCKv9/img-Goio0l-S0i81-NUNa-BIx-Eh-CT6-L.png)

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

You can pass the language of the audio file to improve transcription quality. Supported languages are listed [here](https://github.com/openai/whisper#available-models-and-languages). You need to provide the language as an ISO-639-1 code, eg. "en" for English or "ne" for Nepali. You can look up the codes [here](https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes).

```ruby
response = client.audio.transcribe(
    parameters: {
        model: "whisper-1",
        file: File.open("path_to_file", "rb"),
        language: "en" # Optional
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
    voice: "alloy",
    response_format: "mp3", # Optional
    speed: 1.0 # Optional
  }
)
File.binwrite('demo.mp3', response)
# => mp3 file that plays: "This is a speech test!"
```

### Errors

HTTP errors can be caught like this:

```
  begin
    OpenAI::Client.new.models.retrieve(id: "gpt-4o")
  rescue Faraday::Error => e
    raise "Got a Faraday error: #{e}"
  end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

To run all tests, execute the command `bundle exec rake`, which will also run the linter (Rubocop). This repository uses [VCR](https://github.com/vcr/vcr) to log API requests.

> [!WARNING]
> If you have an `OPENAI_ACCESS_TOKEN` in your `ENV`, running the specs will use this to run the specs against the actual API, which will be slow and cost you money - 2 cents or more! Remove it from your environment with `unset` or similar if you just want to run the specs against the stored VCR responses.

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
