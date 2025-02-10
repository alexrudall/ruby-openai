module OpenAI
  class Client
    include OpenAI::HTTP

    SENSITIVE_ATTRIBUTES = %i[@access_token @admin_token @organization_id @extra_headers].freeze
    CONFIG_KEYS = %i[access_token admin_token api_type api_version extra_headers
                     log_errors organization_id request_timeout uri_base].freeze
    attr_reader *CONFIG_KEYS, :faraday_middleware
    attr_writer :access_token

    def initialize(config = {}, &faraday_middleware)
      CONFIG_KEYS.each do |key|
        # Set instance variables like api_type & access_token. Fall back to global config
        # if not present.
        instance_variable_set(
          "@#{key}",
          config[key].nil? ? OpenAI.configuration.send(key) : config[key]
        )
      end
      @faraday_middleware = faraday_middleware
    end

    def chat(parameters: {})
      json_post(path: "/chat/completions", parameters: parameters)
    end

    def embeddings(parameters: {})
      json_post(path: "/embeddings", parameters: parameters)
    end

    def completions(parameters: {})
      json_post(path: "/completions", parameters: parameters)
    end

    def audio
      @audio ||= OpenAI::Audio.new(client: self)
    end

    def files
      @files ||= OpenAI::Files.new(client: self)
    end

    def finetunes
      @finetunes ||= OpenAI::Finetunes.new(client: self)
    end

    def images
      @images ||= OpenAI::Images.new(client: self)
    end

    def models
      @models ||= OpenAI::Models.new(client: self)
    end

    def assistants
      @assistants ||= OpenAI::Assistants.new(client: self)
    end

    def threads
      @threads ||= OpenAI::Threads.new(client: self)
    end

    def messages
      @messages ||= OpenAI::Messages.new(client: self)
    end

    def runs
      @runs ||= OpenAI::Runs.new(client: self)
    end

    def run_steps
      @run_steps ||= OpenAI::RunSteps.new(client: self)
    end

    def vector_stores
      @vector_stores ||= OpenAI::VectorStores.new(client: self)
    end

    def vector_store_files
      @vector_store_files ||= OpenAI::VectorStoreFiles.new(client: self)
    end

    def vector_store_file_batches
      @vector_store_file_batches ||= OpenAI::VectorStoreFileBatches.new(client: self)
    end

    def batches
      @batches ||= OpenAI::Batches.new(client: self)
    end

    def moderations(parameters: {})
      json_post(path: "/moderations", parameters: parameters)
    end

    def usage
      @usage ||= OpenAI::Usage.new(client: self)
    end

    def azure?
      @api_type&.to_sym == :azure
    end

    def admin
      unless admin_token
        e = "You must set an OPENAI_ADMIN_TOKEN= to use administrative endpoints:\n\n  https://platform.openai.com/settings/organization/admin-keys"
        raise AuthenticationError, e
      end

      dup.tap do |client|
        client.access_token = client.admin_token
      end
    end

    def beta(apis)
      dup.tap do |client|
        client.add_headers("OpenAI-Beta": apis.map { |k, v| "#{k}=#{v}" }.join(";"))
      end
    end

    def inspect
      vars = instance_variables.map do |var|
        value = instance_variable_get(var)

        SENSITIVE_ATTRIBUTES.include?(var) ? "#{var}=[REDACTED]" : "#{var}=#{value.inspect}"
      end

      "#<#{self.class}:#{object_id} #{vars.join(', ')}>"
    end
  end
end
