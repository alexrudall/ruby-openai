require "openai"

module OpenAI
  # OpenAI uses a simple SSE implementation with no 'event:' lines,
  # and they emit a message "[DONE]\n\n" at the end of their response.
  # All of their data messages are JSON, and so we parse those here too.
  class SSE
    class Error < OpenAI::Error; end
    class AbortedStreamError < Error; end
    class InvalidStreamError < Error; end

    def initialize(&on_json_message)
      @buffer = String.new
      @done = false
      @on_json_message = on_json_message
    end

    def feed(data)
      @buffer << data
      while (message = @buffer.slice!(/.*?\n\n/m))
        # "data: a\ndata: b\n\n" -> ["data: a\n", "data: b\n"]
        lines = message.chomp.lines
        raise(InvalidStreamError, "Unexpected multiline SSE message: #{message}") if lines.size > 1

        feed_line(lines[0])
      end
    end

    def finalize!
      unless @done
        raise(AbortedStreamError, "Stream didn't send [DONE] message before finalization.")
      end
      return if @buffer.empty?

      raise(
        AbortedStreamError,
        "Stream still had unprocessed messages at finalization: #{@buffer.inspect}"
      )
    end

    private

    def feed_line(line)
      raise(InvalidStreamError, "Unexpected SSE message: message after [DONE].") if @done

      unless (md = line.match(/\Adata: (?<data>.+)\z/m))
        # OpenAI never sends 'event: ' lines so we don't handle them.
        raise(InvalidStreamError, "Unexpected SSE message format: #{line.inspect}")
      end

      message = md[:data]

      if message == "[DONE]\n"
        @done = true
      else
        @on_json_message.call(JSON.parse(message))
      end
    end
  end
end
