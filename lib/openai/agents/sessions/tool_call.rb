require "json"
require "securerandom"

module OpenAI
  class Agents
    # Runs a registered tool handler for a function call item and submits the result
    # back to the session as an `agent.session.input.tool_result` event.
    class ToolCall
      TOOL_RESULT = "agent.session.input.tool_result".freeze
      HANDLER_ERROR = "Tool handler failed.".freeze
      RETRY_DELAYS = [0.1, 0.3, 0.6].freeze

      def initialize(sessions:, session_id:, call:, handler:)
        @sessions = sessions
        @session_id = session_id
        @call = call
        @handler = handler
      end

      # Returns the function call item announced by a turn event, or nil.
      def self.from_event(event, type)
        return unless type == "agent.session.turn.item.added"

        call = event["item"]
        call if call.is_a?(Hash) && call["type"] == "function_call"
      end

      def submit
        delays = RETRY_DELAYS.dup
        result = build_result
        begin
          post(result)
        rescue Faraday::BadRequestError => e
          delay = delays.shift
          raise unless delay && pending_call_race?(e)

          sleep(delay)
          retry
        end
      end

      private

      def post(result)
        @sessions.events.create(
          session_id: @session_id,
          idempotency_key: SecureRandom.uuid,
          parameters: { events: [result] }
        )
      end

      def build_result
        base = { type: TOOL_RESULT, turn_id: @call["turn_id"], call_id: @call["call_id"] }
        base.merge(success: true, output: output)
      rescue StandardError
        base.merge(success: false, error: HANDLER_ERROR)
      end

      def output
        arguments = parse_arguments(@call["arguments"])
        raise ArgumentError, "Function arguments must be a JSON object" unless arguments.is_a?(Hash)

        output = @handler.call(arguments)
        output = output.to_json if output.is_a?(Hash)
        return output if output.nil? || output.is_a?(String) || output.is_a?(Array)

        raise ArgumentError, "Tool output must be a String, Hash, Array or nil"
      end

      def parse_arguments(arguments)
        arguments.is_a?(String) ? JSON.parse(arguments) : arguments
      rescue JSON::ParserError
        nil
      end

      # The API can briefly reject a tool result submitted right after the call was
      # announced. Only that specific error is retried.
      def pending_call_race?(error)
        body = error.response.is_a?(Hash) ? error.response[:body] : nil
        body = JSON.parse(body) if body.is_a?(String)
        message = body.is_a?(Hash) ? body.dig("error", "message") : nil
        message == "Unknown pending tool call: #{@call['call_id']}"
      rescue JSON::ParserError
        false
      end
    end
  end
end
