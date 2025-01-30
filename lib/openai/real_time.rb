require "faye/websocket"
require "eventmachine"

module OpenAI
  class RealTime
    include HTTPHeaders

    def initialize(client:)
      @client = client
      @websocket = nil
      @on_message = nil
    end

    def on_message(&block)
      @on_message = block
    end

    def connect(model: "gpt-4o-realtime-preview-2024-10-01")
      uri = "#{File.join(@client.websocket_uri_base, @client.api_version, 'realtime')}?model=#{model}"

      EM.run do
        @websocket = Faye::WebSocket::Client.new(uri, nil, headers: openai_realtime_headers)
        @websocket.on :message, @on_message
      end
    end

    def send_event(event)
      @websocket.send(event)
    end
  end
end
