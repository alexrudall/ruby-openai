module AgentsHelpers
  AGENTS_MODEL = "gpt-5.4-mini".freeze

  # Poll until the session is idle. Sleeps only when hitting the real API, so playback from
  # cassettes stays fast.
  def wait_for_idle_session(client, session_id, attempts: 30)
    attempts.times do
      session = client.agents.sessions.retrieve(id: session_id)
      if session["status"] == "idle"
        # Give the runtime a moment to settle; submitting input immediately after the
        # transition to idle can return 409 "session runtime changed during update".
        sleep(3) if ENV.fetch("OPENAI_ACCESS_TOKEN", nil)
        return session
      end

      sleep(2) if ENV.fetch("OPENAI_ACCESS_TOKEN", nil)
    end
    raise "session #{session_id} did not become idle"
  end

  def wait_for_turn_count(client, session_id, count, attempts: 30)
    attempts.times do
      turns = client.agents.sessions.turns.list(session_id: session_id)
      return turns if turns["data"].length >= count

      sleep(2) if ENV.fetch("OPENAI_ACCESS_TOKEN", nil)
    end
    raise "session #{session_id} did not reach #{count} turns"
  end

  def wait_for_connected_environment(client, environment_id, attempts: 60)
    attempts.times do
      environment = client.agents.environments.retrieve(id: environment_id)
      return environment if environment["status"] == "connected"

      sleep(3) if ENV.fetch("OPENAI_ACCESS_TOKEN", nil)
    end
    raise "environment #{environment_id} did not connect"
  end

  def sse_body(frames)
    frames.map { |type, data| "event: #{type}\ndata: #{data.to_json}\n\n" }.join
  end
end

RSpec.configure { |c| c.include AgentsHelpers }
