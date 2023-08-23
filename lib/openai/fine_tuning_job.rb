module OpenAI
  class FineTuningJob
    def initialize(client:)
      @client = client
    end

    def list(id:)
      @client.get(path: "/fine_tuning/jobs/#{id}/events")
    end

    def create(parameters: {})
      @client.json_post(path: "/fine_tuning/jobs", parameters: parameters)
    end

    def retrieve(id:)
      @client.get(path: "/fine_tuning/jobs/#{id}")
    end

    def cancel(id:)
      @client.post(path: "/fine_tuning/jobs/#{id}/cancel")
    end
  end
end
