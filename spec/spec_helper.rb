require "bundler/setup"
require "dotenv/load"
require "openai"
require "openai/compatibility"
require "vcr"

Dir[File.expand_path("spec/support/**/*.rb")].sort.each { |f| require f }

VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir = "spec/fixtures/cassettes"
  c.default_cassette_options = { record: ENV["NO_VCR"] == "true" ? :all : :new_episodes,
                                 match_requests_on: [:method, :uri, VCRMultipartMatcher.new] }
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

  OpenAI.configure do |config|
    # to re-generate the recordings you need to have these in your ENV
    config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN") do
      if ENV["CI"] # rubocop:disable Style/GuardClause
        "secret-needed-to-record-new-tests"
      else
        raise KeyError, "OPENAI_ACCESS_TOKEN must be in the ENV when not running in CI"
      end
    end
  end
end

RSPEC_ROOT = File.dirname __FILE__
