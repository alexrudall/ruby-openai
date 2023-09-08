module OpenAI
  module HTTP
    # Heavily borrowed from Faraday::Error
    # https://github.com/lostisland/faraday/blob/ea30bd0b543882f1cf26e75ac4e46e0705fa7e68/lib/faraday/error.rb
    class Error < ::OpenAI::Error
      attr_reader :response, :wrapped_exception

      def initialize(exc = nil, response = nil)
        @wrapped_exception = nil unless defined?(@wrapped_exception)
        @response = nil unless defined?(@response)
        super(exc_msg_and_response!(exc, response))
      end

      def backtrace
        if @wrapped_exception
          @wrapped_exception.backtrace
        else
          super
        end
      end

      def inspect
        inner = +''
        inner << " wrapped=#{@wrapped_exception.inspect}" if @wrapped_exception
        inner << " response=#{@response.inspect}" if @response
        inner << " #{super}" if inner.empty?
        %(#<#{self.class}#{inner}>)
      end

      def response_status
        return unless @response

        @response.respond_to?(:status) ? @response.status : @response[:status]
      end

      def response_headers
        return unless @response

        @response.response_to?(:headers) ? @response.headers : @response[:headers]
      end

      def response_body
        return unless @response

        @response.respond_to?(:body) ? @response.body : @response[:body]
      end

      protected

      # Pulls out potential parent exception and response hash, storing them in
      # instance variables.
      # exc      - Either an Exception, a string message, or a response hash.
      # response - Hash
      #              :status  - Optional integer HTTP response status
      #              :headers - String key/value hash of HTTP response header
      #                         values.
      #              :body    - Optional string HTTP response body.
      #              :request - Hash
      #                           :method   - Symbol with the request HTTP method.
      #                           :url      - URI object with the url requested.
      #                           :url_path - String with the url path requested.
      #                           :params   - String key/value hash of query params
      #                                     present in the request.
      #                           :headers  - String key/value hash of HTTP request
      #                                     header values.
      #                           :body     - String HTTP request body.
      #
      # If a subclass has to call this, then it should pass a string message
      # to `super`. See NilStatusError.
      def exc_msg_and_response!(exc, response = nil)
        if @response.nil? && @wrapped_exception.nil?
          @wrapped_exception, msg, @response = exc_msg_and_response(exc, response)
          return msg
        end

        exc.to_s
      end

      # Pulls out potential parent exception and response hash.
      def exc_msg_and_response(exc, response = nil)
        return [exc, exc.message, response] if exc.respond_to?(:backtrace)

        return [nil, "the server responded with status #{exc[:status]}", exc] if exc.respond_to?(:each_key)

        [nil, exc.to_s, response]
      end
    end
  end
end
