require "faye/websocket"
require "eventmachine"

module OpenAI
  class RealTime
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
      headers = {
        "Authorization" => "Bearer #{@client.access_token}",
        "OpenAI-Beta" => "realtime=v1"
      }
      EM.run do
        @websocket = Faye::WebSocket::Client.new(uri, nil, headers: headers)
        @websocket.on :message, @on_message
      end
    end

    def send_event(event)
      @websocket.send(event)
    end
  end
end
