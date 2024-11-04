require "faye/websocket"
require "eventmachine"

module OpenAI
  class RealTime
    def initialize(client:)
      @client = client
      @websocket = nil
    end

    def connect(&block)
      url = "wss://api.openai.com/v1/realtime?model=gpt-4o-realtime-preview-2024-10-01"
      headers = {
        "Authorization" => "Bearer #{@client.access_token}",
        "OpenAI-Beta" => "realtime=v1"
      }
      EM.run do
        @websocket = Faye::WebSocket::Client.new(url, nil, headers: headers)
        @websocket.on :message, &block
      end
    end

    def send_event(event)
      @websocket.send(event)
    end
  end
end
