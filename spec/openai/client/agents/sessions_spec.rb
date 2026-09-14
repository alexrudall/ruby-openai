RSpec.describe OpenAI::Client do
  describe "#agents.sessions" do
    let(:client) { OpenAI::Client.new }
    let(:session_parameters) do
      {
        environment: { type: "none" },
        agent: { model: AgentsHelpers::AGENTS_MODEL, instructions: "Reply with one word." },
        input: "Say hi"
      }
    end
    let(:session_id) do
      VCR.use_cassette("#{cassette} setup") do
        id = client.agents.sessions.create(parameters: session_parameters)["id"]
        wait_for_idle_session(client, id)
        id
      end
    end

    describe "#create" do
      let(:cassette) { "agents sessions create" }

      it "creates a session" do
        VCR.use_cassette(cassette) do
          response = client.agents.sessions.create(parameters: session_parameters)
          expect(response["object"]).to eq("agent.session")
          expect(response["environment"]["type"]).to eq("none")
        end
      end

      context "with a stream proc" do
        let(:events) { [] }
        let(:body) do
          sse_body(
            [
              ["agent.session.created",
               { "type" => "agent.session.created", "event_id" => "evt_1" }],
              ["agent.session.idle", { "type" => "agent.session.idle", "event_id" => "evt_2" }]
            ]
          )
        end

        before do
          stub_request(:post, "https://api.openai.com/v1/agents/sessions")
            .with(body: hash_including("stream" => true))
            .to_return(status: 200, body: body, headers: { "Content-Type" => "text/event-stream" })
        end

        it "yields each parsed event with its type" do
          client.agents.sessions.create(
            parameters: session_parameters.merge(stream: proc { |event, type|
              events << [type, event]
            })
          )
          expect(events.map(&:first)).to eq(["agent.session.created", "agent.session.idle"])
          expect(events.last.last["event_id"]).to eq("evt_2")
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "agents sessions retrieve" }

      it "retrieves the session" do
        VCR.use_cassette(cassette) do
          response = client.agents.sessions.retrieve(id: session_id)
          expect(response["id"]).to eq(session_id)
          expect(response["object"]).to eq("agent.session")
        end
      end
    end

    describe "#update" do
      let(:cassette) { "agents sessions update" }

      it "updates the session metadata" do
        VCR.use_cassette(cassette) do
          response = client.agents.sessions.update(id: session_id,
                                                   parameters: { metadata: { env: "spec" } })
          expect(response["metadata"]).to eq({ "env" => "spec" })
        end
      end
    end

    describe "#list" do
      let(:cassette) { "agents sessions list" }

      it "lists sessions" do
        VCR.use_cassette(cassette) do
          session_id
          response = client.agents.sessions.list(parameters: { limit: 5 })
          expect(response["object"]).to eq("list")
          expect(response["data"]).to be_an(Array)
        end
      end
    end

    describe "#delete" do
      let(:cassette) { "agents sessions delete" }

      it "deletes the session" do
        VCR.use_cassette(cassette) do
          response = client.agents.sessions.delete(id: session_id)
          expect(response["deleted"]).to be(true)
        end
      end
    end
  end
end
