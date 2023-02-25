module OpenAI
  class Client
    URI_BASE = "https://api.openai.com/".freeze

    def initialize(access_token: nil, organization_id: nil, max_concurrency: 200, rate_limit: 3000)
      OpenAI.configuration.access_token = access_token if access_token
      OpenAI.configuration.organization_id = organization_id if organization_id

      # OpenAI has a 3000 request/min hard rate limit if your account is over 48 hours old,
      # so we're defaulting to that, but allowing smaller if you want
      @rate_queue = Limiter::RateQueue.new(rate_limit, interval: 60)

      # The default is 200 connections, so that's the default we're keeping here
      @hydra = Typhoeus::Hydra.new(max_concurrency: max_concurrency)
    end

    def completions(parameters: {})
      OpenAI::Client.json_post(path: "/completions", parameters: parameters)
    end

    def queue_completions(parameters: {}, &block)
      request = OpenAI::Client.queue_json_post(
        path: "/completions",
        parameters: parameters,
        rate_queue: @rate_queue,
        &block
      )
      @hydra.queue(request)
    end

    def edits(parameters: {})
      OpenAI::Client.json_post(path: "/edits", parameters: parameters)
    end

    def queue_edits(parameters: {}, &block)
      request = OpenAI::Client.queue_json_post(
        path: "/edits",
        parameters: parameters,
        rate_queue: @rate_queue,
        &block
      )
      @hydra.queue(request)
    end

    def embeddings(parameters: {})
      OpenAI::Client.json_post(path: "/embeddings", parameters: parameters)
    end

    def queue_embeddings(parameters: {}, &block)
      request = OpenAI::Client.queue_json_post(
        path: "/embeddings",
        parameters: parameters,
        rate_queue: @rate_queue,
        &block
      )
      @hydra.queue(request)
    end

    def run_queued_requests
      @hydra.run
    end

    def files
      @files ||= OpenAI::Files.new
    end

    def finetunes
      @finetunes ||= OpenAI::Finetunes.new
    end

    def images
      @images ||= OpenAI::Images.new
    end

    def models
      @models ||= OpenAI::Models.new
    end

    def moderations(parameters: {})
      OpenAI::Client.json_post(path: "/moderations", parameters: parameters)
    end

    def self.get(path:)
      Typhoeus.get(
        uri(path: path),
        headers: headers
      )
    end

    def self.queue_get(path:, rate_queue:, &block)
      request = Typhoeus::Request.new(path)

      request.on_complete do |response|
        rate_queue.shift
        block.call(response)
      end

      request
    end

    def self.json_post(path:, parameters:)
      Typhoeus.post(
        uri(path: path),
        headers: headers,
        body: parameters&.to_json
      )
    end

    def self.queue_json_post(path:, parameters:, rate_queue:, &block)
      request = Typhoeus::Request.new(
        uri(path: path),
        method: :post,
        headers: headers,
        body: parameters&.to_json
      )

      request.on_complete do |response|
        rate_queue.shift
        block.call(response)
      end

      request
    end

    def self.multipart_post(path:, parameters: nil)
      Typhoeus.post(
        uri(path: path),
        headers: headers.merge({ "Content-Type" => "multipart/form-data" }),
        body: parameters
      )
    end

    def self.queue_multipart_post(path:, parameters: nil, rate_queue:, &block)
      request = Typhoeus.request(
        uri(path: path),
        method: :post,
        headers: headers.merge({ "Content-Type" => "multipart/form-data" }),
        body: parameters
      )

      request.on_complete do |response|
        rate_queue.shift
        block.call(response)
      end

      request
    end

    def self.delete(path:)
      Typhoeus.delete(
        uri(path: path),
        headers: headers
      )
    end

    def self.queue_delete(path:, rate_queue:, &block)
      request = Typhoeus.request(
        uri(path: path),
        method: :delete,
        headers: headers
      )

      request.on_complete do |response|
        rate_queue.shift
        block.call(response)
      end

      request
    end

    private_class_method def self.uri(path:)
      URI_BASE + OpenAI.configuration.api_version + path
    end

    private_class_method def self.headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{OpenAI.configuration.access_token}",
        "OpenAI-Organization" => OpenAI.configuration.organization_id
      }
    end
  end
end
