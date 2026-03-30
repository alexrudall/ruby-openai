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
      return accumulate_error_body(chunk, env) if env&.status && env.status != 200

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

    def accumulate_error_body(chunk, env)
      @error_body = (@error_body || "") + chunk
      return if @error_body_callback_set

      env.response.on_complete { |e| e.body = @error_body }
      @error_body_callback_set = true
    end
  end
end
