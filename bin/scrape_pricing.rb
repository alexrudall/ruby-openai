#!/usr/bin/env ruby

require "playwright"
require "base64"
require_relative "../lib/openai"

begin
  playwright_path = `which playwright`.strip
  abort "playwright not found. Please install playwright with `npm install -g playwright && playwright install`" if playwright_path.empty?
  chrome_path = `which chrome`.strip
  chrome_path = `which chromium`.strip if chrome_path.empty?
  abort "Neither chromium nor chrome found. Please install chromium before continuing" if chrome_path.empty?

  abort "OPENAI_ACCESS_TOKEN not set. Please set the OPENAI_ACCESS_TOKEN environment variable before continuing" if ENV["OPENAI_ACCESS_TOKEN"]&.empty?

  pricing_data = ""
  
  Playwright.create(playwright_cli_executable_path: playwright_path) do |playwright|
    chromium = playwright.chromium
    browser = chromium.launch(
      headless: false,
      args: ["--window-size=1920,1080"]
    )
    
    puts "reading pricing data from openai pricing page"
    page = browser.new_page
    page.goto("https://openai.com/api/pricing/")
    
    puts "Waiting for the page to be fully loaded"
    page.wait_for_load_state(state: "domcontentloaded")

    puts "extracting pricing data from the page"
    elements = page.query_selector_all("div.m\\:max-w-container").take(5)
    
    pricing_data = elements.map do |element|
      rows = element.query_selector_all("div.grid-cols-autofit")
      rows.map do |row|
        # Get all cells in the row
        cells = row.query_selector_all("div.m\\:border-l-\\[1px\\]")
        
        # Extract text from each cell, strip whitespace, and filter out empty cells
        row_data = cells.map { |cell| cell.text_content.strip }.reject(&:empty?)
        row_data if row_data.any?
      end.compact
    end
    
    puts "\nPricing Table Data:"
    pricing_data.each do |row|
      puts row.join(" | ")
    end
    
    browser.close
  end

  puts "processing pricing data"
  OpenAI.configure do |config|
    config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")
    config.log_errors = true # Highly recommended in development, so you can see what errors OpenAI is returning. Not recommended in production because it could leak private data to your logs.
  end

  client = OpenAI::Client.new    
  messages = [
    { 
      role: "user", 
      content: [
        { 
          type: "text", 
          text: DATA.read.gsub("<%= pricing_data %>", pricing_data.to_s) 
        }
      ]
    }
  ]

  response = client.chat(parameters: {
    model: "gpt-4o-mini",
    messages: messages
  })


  pricing = response.dig("choices", 0, "message", "content").strip.downcase
  puts pricing
rescue => e
  puts "An error occurred: #{e.class} - #{e.message}"
  puts e.backtrace
end

__END__

You are a openai developer and salesperson. 
I'll give you a pricing table and you'll extract the pricing details from each model.

## Instructions

Read the data provided in the `# Pricing data to process` section. 
Extract the pricing details from each model.
Format the data as a ruby hash with the following keys: 
* model
* input
* cached input
* output
* audio input
* audio output

Use plain numbers for the prices without any currency notation.
Take into account that audio-enabled models (e.g. gpt-4o-audio-preview-2024-12-17) there's no input cached nor batch pricing, take the values from the Text section. 

Respond with the ruby hash as plain text without any formatting ready to be written to a ruby file.

## Input data format

The structure of the pricing data table for text-only models is:

```
<model> | <input> | <batch input> 
<cached input>
<output> | <cached output>
```

The structure of the pricing data table for audio-enabled models is:
```
<model> | "Text"
<input> 
<output>
"Audio"
<input> 
<output>
```
## Example
Given the following pricing data:

```
Pricing Table Data:
gpt-4o | $2.50 / 1M input tokens | $1.25 / 1M input tokens
$1.25 / 1M cached** input tokens
$10.00 / 1M output tokens | $5.00 / 1M output tokens
gpt-4o-2024-11-20 | $2.50 / 1M input tokens | $1.25 / 1M input tokens
gpt-4o-audio-preview | Text
$2.50 / 1M input tokens
$10.00 / 1M output tokens
Audio
$40.00 / 1M input tokens
$80.00 / 1M output tokens

Pricing Table Data:
o1-mini | $3.00 / 1M input tokens
$1.50 / 1M cached* input tokens
$12.00 / 1M output** tokens
```

the expected output is:
{
  "gpt-4o" => {input: 2.5, cached_input: 1.25, output: 10.0, audio_input: nil, audio_output: nil},
  "gpt-4o-audio-preview-2024-11-20" => {input: 2.5, cached_input: 2.5, output: 10.0, audio_input: 40.0, audio_output: 80.0},
  "o1-mini" => {input: 3.0, cached_input: 1.5, output: 12.0, audio_input: nil, audio_output: nil},
}

## Pricing Data to process

<%= pricing_data %>
