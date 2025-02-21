require "bundler/setup"
require "dotenv/load"
require "openai"
require "vcr"
require "byebug"

Dir[File.expand_path("spec/support/**/*.rb")].sort.each { |f| require f }

tokens_present = ENV.fetch("OPENAI_ACCESS_TOKEN", nil) && ENV.fetch("OPENAI_ADMIN_TOKEN", nil)

VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir = "spec/fixtures/cassettes"
  c.default_cassette_options = {
    record: tokens_present ? :all : :new_episodes,
    match_requests_on: [:method, :uri, VCRMultipartMatcher.new]
  }

  %w[ACCESS_TOKEN ADMIN_TOKEN ORGANIZATION_ID USER_ID].each do |key|
    c.filter_sensitive_data("<OPENAI_#{key}>") do
      key == "USER_ID" ? ENV.fetch("OPENAI_#{key}", nil) : OpenAI.configuration.send(key.downcase)
    end
  end
end

RSpec.configure do |c|
  # Enable flags like --only-failures and --next-failure
  c.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  c.disable_monkey_patching!

  c.expect_with(:rspec) { |rspec| rspec.syntax = :expect }

  if tokens_present
    warning = "WARNING! Specs are hitting the OpenAI API using your OPENAI_ACCESS_TOKEN or
    OPENAI_ADMIN_TOKEN! This costs at least 2 cents per run and is very slow! If you don't want
    this, unset OPENAI_ACCESS_TOKEN to just run against the stored VCR responses.".freeze
    warning = RSpec::Core::Formatters::ConsoleCodes.wrap(warning, :bold_red)

    c.before(:suite) { RSpec.configuration.reporter.message(warning) }
    c.after(:suite) { RSpec.configuration.reporter.message(warning) }
  end

  c.before(:all) do
    OpenAI.configure do |config|
      config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN", "dummy-token")
      config.admin_token = ENV.fetch("OPENAI_ADMIN_TOKEN", "dummy-token")
      config.organization_id = ENV.fetch("OPENAI_ORGANIZATION_ID", nil)
    end
  end
end

RSPEC_ROOT = File.dirname __FILE__
