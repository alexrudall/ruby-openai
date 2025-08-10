module OpenAI
  class Realtime
    def initialize(client:)
      @client = client.beta(realtime: "v1")
    end

    # Create a new real-time session with OpenAI.
    #
    # This method sets up a new session for real-time voice interaction with an OpenAI model.
    # It returns session details that can be used to establish a WebRTC connection.
    #
    # @param parameters [Hash] parameters for the session (see: https://platform.openai.com/docs/api-reference/realtime-sessions/create)
    # @return [Hash] Session details including session ID, ICE servers, and other
    # connection information
    def create(parameters: {})
      @client.json_post(path: "/realtime/sessions", parameters: parameters)
    end
  end
end
