module OpenAI
  class Stream
    DONE = "[DONE]".freeze
    private_constant :DONE

    def initialize(user_proc:, parser: EventStreamParser::Parser.new)
      @user_proc = user_proc
      @parser = parser

      # To be backwards compatible, we need to check how many arguments the user_proc takes.
      @user_proc_arity =
        case user_proc
        when Proc
          user_proc.arity.abs
        else
          user_proc.method(:call).arity.abs
        end
    end

    def call(chunk, _bytes, env = nil)
      if env && env.status != 200 && @error_env.nil?
        @error_body = +""
        @error_env = env
      end

      if @error_env
        @error_body << chunk

        # Buffer error chunks until we have complete JSON, then raise with
        # the full body. Without this, only the first chunk (often just "{")
        # would be captured, losing the actual API error message.
        parsed = try_parse_json(@error_body)
        unless parsed.is_a?(String)
          raise_error = Faraday::Response::RaiseError.new
          raise_error.on_complete(@error_env.merge(body: parsed))
        end

        # Safety valve: raise with raw body if we've buffered too much
        if @error_body.bytesize > 65_536
          raise_error = Faraday::Response::RaiseError.new
          raise_error.on_complete(@error_env.merge(body: @error_body))
        end

        return
      end

      parser.feed(chunk) do |event, data|
        next if data == DONE

        args = [JSON.parse(data), event].first(user_proc_arity)
        user_proc.call(*args)
      end
    end

    def to_proc
      method(:call).to_proc
    end

    private

    attr_reader :user_proc, :parser, :user_proc_arity

    def try_parse_json(maybe_json)
      JSON.parse(maybe_json)
    rescue JSON::ParserError
      maybe_json
    end
  end
end
