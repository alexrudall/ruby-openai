require "securerandom"
require_relative "tool_call"

module OpenAI
  class Agents
    # Runs one turn on an idle agent session: submits the input, follows the session's
    # event stream, invokes registered tool handlers for function calls, and stops once
    # the session is idle again or has failed.
    #
    # The caller must be the session's only input writer while the turn runs. Closing
    # the event stream does not cancel the turn on the server.
    class SessionStream
      INPUT_MESSAGE = "agent.session.input.message".freeze
      TURN_ENDED_EVENTS = %w[
        agent.session.turn.completed
        agent.session.turn.failed
        agent.session.turn.cancelled
      ].freeze
      MAX_SEEN_EVENTS = 1024

      def initialize(sessions:, session_id:, input:, tool_handlers: {}, idempotency_key: nil)
        @sessions = sessions
        @session_id = session_id
        @messages = normalize_input(input)
        @handlers = tool_handlers.to_h.transform_keys(&:to_s)
        @idempotency_key = idempotency_key || SecureRandom.uuid
        @seen_events = {}
        @handled_calls = {}
        @turn_id = nil
        @turn_ended = false
      end

      # Yields each event as (event, type) and returns nil once the turn has finished.
      def run(&block)
        ensure_idle!
        queue = Queue.new
        reader = start_reader(queue)
        submit_input
        consume(queue, &block)
        nil
      ensure
        reader&.kill
      end

      private

      def consume(queue)
        loop do
          type, event = queue.pop
          raise OpenAI::Error, "Session event stream ended before the turn finished" if type == :eof
          raise event if type == :error
          next if duplicate?(event)

          track_turn(event, type)
          yield(event, type) if block_given?
          break if terminal?(type)

          handle_function_call(event, type)
        end
      end

      def normalize_input(input)
        raise ArgumentError, "input must not be empty" if input.to_s.empty? || Array(input).empty?
        return Array(input) unless input.is_a?(String)

        [{ role: "user", content: [{ type: "input_text", text: input }] }]
      end

      def ensure_idle!
        session = @sessions.retrieve(id: @session_id)
        return if session["status"] == "idle"

        raise ArgumentError, "sessions.stream requires an idle session, " \
                             "but its status is #{session['status']}"
      end

      def start_reader(queue)
        Thread.new do
          Thread.current.report_on_exception = false
          @sessions.events.stream(session_id: @session_id, stream: ->(e, t) { queue << [t, e] })
          queue << [:eof, nil]
        rescue StandardError => e
          queue << [:error, e]
        end
      end

      def submit_input
        @sessions.events.create(
          session_id: @session_id,
          idempotency_key: @idempotency_key,
          parameters: { events: [{ type: INPUT_MESSAGE, input: @messages }] }
        )
      end

      def duplicate?(event)
        id = event["event_id"]
        return false if id.nil?
        return true if @seen_events.key?(id)

        @seen_events.shift if @seen_events.size >= MAX_SEEN_EVENTS
        @seen_events[id] = true
        false
      end

      def track_turn(event, type)
        case type
        when "agent.session.turn.created"
          @turn_id ||= event["turn_id"] if event.dig("turn", "subagent_id").nil?
        when *TURN_ENDED_EVENTS
          @turn_ended = true if @turn_id && event["turn_id"] == @turn_id
        end
      end

      def terminal?(type)
        type == "agent.session.failed" || (type == "agent.session.idle" && @turn_ended)
      end

      def handle_function_call(event, type)
        call = ToolCall.from_event(event, type)
        return unless call

        key = [call["turn_id"], call["call_id"]]
        return if @handled_calls.key?(key)

        @handled_calls[key] = true
        handler = @handlers[call["name"]]
        return unless handler

        ToolCall.new(sessions: @sessions, session_id: @session_id, call: call,
                     handler: handler).submit
      end
    end
  end
end
