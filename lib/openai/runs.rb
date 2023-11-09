module OpenAI
  class Runs
    def initialize(client:)
      @client = client.beta(assistants: "v1")
    end

    def list(thread_id:)
      @client.get(path: "/threads/#{thread_id}/runs")
    end

    def retrieve(thread_id:, id:)
      @client.get(path: "/threads/#{thread_id}/runs/#{id}")
    end

    def create(thread_id:, parameters: {})
      @client.json_post(path: "/threads/#{thread_id}/runs", parameters: parameters)
    end

    def modify(id:, thread_id:, parameters: {})
      @client.json_post(path: "/threads/#{thread_id}/runs/#{id}", parameters: parameters)
    end

    def submit_tool_outputs(thread_id:, run_id:, parameters: {})
      @client.json_post(path: "/threads/#{thread_id}/runs/#{run_id}/submit_tool_outputs",
                        parameters: parameters)
    end
  end
end
