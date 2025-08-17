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
      handle_http_error(chunk: chunk, env: env) if env && env.status != 200

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

    def handle_http_error(chunk:, env:)
      raise_error = Faraday::Response::RaiseError.new
      raise_error.on_complete(env.merge(body: try_parse_json(chunk)))
    end

    def try_parse_json(maybe_json)
      JSON.parse(maybe_json)
    rescue JSON::ParserError
      maybe_json
    end
  end
end
