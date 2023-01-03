require "bundler/setup"
require "dotenv/load"
require "ruby/openai"
require "vcr"

VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir = "spec/fixtures/cassettes"
  c.default_cassette_options = { record: ENV["NO_VCR"].nil? ? :new_episodes : :all }
  c.filter_sensitive_data("<OPENAI_ACCESS_TOKEN>") { OpenAI.configuration.access_token }
  c.filter_sensitive_data("<OPENAI_ORGANIZATION_ID>") { OpenAI.configuration.organization_id }
end

RSpec.configure do |c|
  # Enable flags like --only-failures and --next-failure
  c.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  c.disable_monkey_patching!

  c.expect_with :rspec do |rspec|
    rspec.syntax = :expect
  end

  c.before(:all) do
    OpenAI.configure do |config|
      config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")
    end
  end
end

RSPEC_ROOT = File.dirname __FILE__
