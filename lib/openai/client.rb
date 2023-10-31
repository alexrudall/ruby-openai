module OpenAI
  class Client
    include OpenAI::HTTP

    CONFIG_KEYS = %i[
      api_type
      api_version
      access_token
      organization_id
      uri_base
      request_timeout
      extra_headers
    ].freeze
    attr_reader *CONFIG_KEYS

    def initialize(config = {})
      CONFIG_KEYS.each do |key|
        # Set instance variables like api_type & access_token. Fall back to global config
        # if not present.
        instance_variable_set("@#{key}", config[key] || OpenAI.configuration.send(key))
      end
    end

    def chat(parameters: {})
      json_post(path: "/chat/completions", parameters: parameters)
    end

    def edits(parameters: {})
      json_post(path: "/edits", parameters: parameters)
    end

    def embeddings(parameters: {})
      json_post(path: "/embeddings", parameters: parameters)
    end

    def audio
      @audio ||= OpenAI::Audio.new(client: self)
    end

    def files
      @files ||= OpenAI::Files.new(client: self)
    end

    def fine_tuning_jobs
      @fine_tuning_jobs ||= OpenAI::FineTuningJobs.new(client: self)
    end

    def images
      @images ||= OpenAI::Images.new(client: self)
    end

    def models
      @models ||= OpenAI::Models.new(client: self)
    end

    def moderations(parameters: {})
      json_post(path: "/moderations", parameters: parameters)
    end

    def azure?
      @api_type&.to_sym == :azure
    end
  end
end
