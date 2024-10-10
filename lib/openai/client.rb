module OpenAI
  class Client
    include OpenAI::HTTP

    SENSITIVE_ATTRIBUTES = %i[@access_token @organization_id @extra_headers].freeze
    CONFIG_KEYS = %i[
      api_type
      api_version
      access_token
      log_errors
      organization_id
      uri_base
      request_timeout
      extra_headers
    ].freeze
    attr_reader *CONFIG_KEYS

    def initialize(config = {}, &faraday_middleware)
      CONFIG_KEYS.each do |key|
        # Set instance variables like api_type & access_token. Fall back to global config
        # if not present.
        instance_variable_set(
          "@#{key}",
          config[key].nil? ? OpenAI.configuration.send(key) : config[key]
        )
      end

      @connection = build_connection
      faraday_middleware&.call(@connection)

      @multipart_connection = build_connection(multipart: true)
      faraday_middleware&.call(@multipart_connection)
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

    def azure?
      @api_type&.to_sym == :azure
    end

    private

    attr_reader :connection, :multipart_connection

    def build_connection(multipart: false)
      Faraday.new do |faraday|
        faraday.options[:timeout] = @request_timeout
        faraday.request(:multipart) if multipart
        faraday.use MiddlewareErrors if @log_errors
        faraday.use MiddlewareBeta
        faraday.response :raise_error
        faraday.response :json
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
