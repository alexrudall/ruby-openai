require_relative "sessions/events"
require_relative "sessions/items"
require_relative "sessions/turns"
require_relative "sessions/subagents"
require_relative "sessions/artifacts"
require_relative "sessions/session_stream"

module OpenAI
  class Agents
    class Sessions
      def initialize(client:)
        @client = client
      end

      # Pass `stream: proc { |event, type| ... }` in parameters to stream the session's
      # events over SSE instead of receiving the session object.
      def create(parameters: {})
        @client.json_post(path: "/agents/sessions", parameters: parameters)
      end

      def retrieve(id:)
        @client.get(path: "/agents/sessions/#{id}")
      end

      def update(id:, parameters: {})
        @client.json_post(path: "/agents/sessions/#{id}", parameters: parameters)
      end

      def list(parameters: {})
        @client.get(path: "/agents/sessions", parameters: parameters)
      end

      def delete(id:)
        @client.delete(path: "/agents/sessions/#{id}")
      end

      # Submit input to an idle session and stream one turn until the session is idle
      # again or has failed. Registered tool handlers are invoked for matching function
      # calls and their results are submitted back to the session automatically.
      #
      #   client.agents.sessions.stream(
      #     id: session_id,
      #     input: "What's the weather in Paris?",
      #     tool_handlers: { "get_weather" => ->(args) { { temperature: 21 } } }
      #   ) { |event, type| puts type }
      def stream(id:, input:, tool_handlers: {}, idempotency_key: nil, &block)
        SessionStream.new(
          sessions: self,
          session_id: id,
          input: input,
          tool_handlers: tool_handlers,
          idempotency_key: idempotency_key
        ).run(&block)
      end

      def events
        @events ||= OpenAI::Agents::Sessions::Events.new(client: @client)
      end

      def items
        @items ||= OpenAI::Agents::Sessions::Items.new(client: @client)
      end

      def turns
        @turns ||= OpenAI::Agents::Sessions::Turns.new(client: @client)
      end

      def subagents
        @subagents ||= OpenAI::Agents::Sessions::Subagents.new(client: @client)
      end

      def artifacts
        @artifacts ||= OpenAI::Agents::Sessions::Artifacts.new(client: @client)
      end
    end
  end
end
