module OpenAI
  class Client
    def initialize(access_token: nil, organization_id: nil, uri_base: nil, request_timeout: nil)
      OpenAI.configuration.access_token = access_token if access_token
      OpenAI.configuration.organization_id = organization_id if organization_id
      OpenAI.configuration.uri_base = uri_base if uri_base
      OpenAI.configuration.request_timeout = request_timeout if request_timeout
    end

    def chat(parameters: {})
      OpenAI::Client.json_post(path: "/chat/completions", parameters: parameters)
    end

    def completions(parameters: {})
      OpenAI::Client.json_post(path: "/completions", parameters: parameters)
    end

    def edits(parameters: {})
      OpenAI::Client.json_post(path: "/edits", parameters: parameters)
    end

    def embeddings(parameters: {})
      OpenAI::Client.json_post(path: "/embeddings", parameters: parameters)
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

    def transcribe(parameters: {})
      OpenAI::Client.multipart_post(path: "/audio/transcriptions", parameters: parameters)
    end

    def translate(parameters: {})
      OpenAI::Client.multipart_post(path: "/audio/translations", parameters: parameters)
    end

    def self.get(path:)
      Response.new HTTParty.get(
        uri(path: path),
        headers: headers,
        timeout: request_timeout
      )
    end

    def self.json_post(path:, parameters:)
      Response.new HTTParty.post(
        uri(path: path),
        headers: headers,
        body: parameters&.to_json,
        timeout: request_timeout
      )
    end

    def self.multipart_post(path:, parameters: nil)
      Response.new HTTParty.post(
        uri(path: path),
        headers: headers.merge({ "Content-Type" => "multipart/form-data" }),
        body: parameters,
        timeout: request_timeout
      )
    end

    def self.delete(path:)
      Response.new HTTParty.delete(
        uri(path: path),
        headers: headers,
        timeout: request_timeout
      )
    end

    private_class_method def self.uri(path:)
      OpenAI.configuration.uri_base + OpenAI.configuration.api_version + path
    end

    private_class_method def self.headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{OpenAI.configuration.access_token}",
        "OpenAI-Organization" => OpenAI.configuration.organization_id
      }
    end

    private_class_method def self.request_timeout
      OpenAI.configuration.request_timeout
    end

    # @note Expects wrapped_response to be a HTTParty::Response
    class Response < BasicObject
      const_set(:SuccessfulStatuses, (200..299).freeze)

      def initialize(wrapped_response)
        @wrapped_response = wrapped_response
      end

      def success?
        return false unless code
        SuccessfulStatuses.include?(code)
      end

      def to_hash
        {
          status: code, body: body,
          response_headers: headers,
          # url: url
        }
      end

      def code
        @wrapped_response.code
      end

      def body
        @wrapped_response.body
      end

      def headers
        @wrapped_response.headers
      end

      def request
        @wrapped_response.request
      end

      def response
        @wrapped_response
      end

      def wrapped_response
        @wrapped_response.response
      end

      KERNEL_METHOD_METHOD = ::Kernel.instance_method(:method)

      # delegate constant lookup to Object
      def self.const_missing(name)
        ::Object.const_get(name)
      end

      # @!visibility private
      def send(*args)
        __send__(*args)
      end

      def method(method_name)
        KERNEL_METHOD_METHOD.bind(self).call(method_name)
      end

      def method_missing(name, *args, &block)
        @wrapped_response.send(name, *args, &block)
      end

      def respond_to_missing?(name, include_private = false)
        @wrapped_response.respond_to?(name, include_private)
      end
    end
  end
end
