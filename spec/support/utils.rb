module Utils
  def self.reset_global_configuration
    OpenAI.configuration.reset
  end

  def self.load_global_configuration
    OpenAI.configure do |config|
      config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")
    end
  end

  def self.fixture_filename(filename:)
    File.join(RSPEC_ROOT, "fixtures/files", filename)
  end
end
