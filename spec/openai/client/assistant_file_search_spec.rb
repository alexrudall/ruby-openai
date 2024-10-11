RSpec.describe OpenAI::Client do
  let(:cassette) { "assistant file search" }
  let(:vector_store_id) do
    VCR.use_cassette("#{cassette} vector_store setup") do
      OpenAI::Client.new.vector_stores.create(parameters: {})["id"]
    end
  end
  let(:filename) { "somatosensory.pdf" }
  let(:filepath) { File.join(RSPEC_ROOT, "fixtures/files", filename) }
  let(:upload_purpose) { "assistants" }
  let(:file_id) do
    VCR.use_cassette("#{cassette} file setup") do
      OpenAI::Client.new.files.upload(
        parameters: {
          file: filepath,
          purpose: "assistants"
        }
      )["id"]
    end
  end
  let!(:vector_store_file_id) do
    VCR.use_cassette("#{cassette} vector_store_file setup") do
      OpenAI::Client.new.vector_store_files.create(
        vector_store_id: vector_store_id,
        parameters: { file_id: file_id }
      )["id"]
    end
  end
  let(:assistant_id) do
    VCR.use_cassette("#{cassette} assistant setup") do
      OpenAI::Client.new.assistants.create(
        parameters: {
          model: "gpt-4o",
          name: "Answer finder",
          instructions: "You are a file search tool. Find the answer in the given files, please.",
          tools: [
            { type: "file_search" }
          ],
          tool_resources: {
            file_search: {
              vector_store_ids: [vector_store_id]
            }
          }
        }
      )["id"]
    end
  end
  let(:thread_id) do
    VCR.use_cassette("#{cassette} thread setup") do
      OpenAI::Client.new.threads.create(parameters: {
                                          messages: [
                                            { role: "user",
                                              content: "Find the description of a nociceptor." }
                                          ]
                                        })["id"]
    end
  end
  let(:run_id) do
    VCR.use_cassette("#{cassette} create run") do
      OpenAI::Client.new.runs.create(
        thread_id: thread_id,
        query_parameters: {
          include: ["step_details.tool_calls[*].file_search.results[*].content"]
        },
        parameters: {
          assistant_id: assistant_id
        }
      )["id"]
    end
  end

  describe "assistant file search" do
    it "includes the chunk(s) found in the file search" do
      VCR.use_cassette("#{cassette} step retrieve") do
        steps = {}
        result = []
        10.times do
          break if result != []

          steps = OpenAI::Client.new.run_steps.list(
            thread_id: thread_id,
            run_id: run_id,
            parameters: { order: "asc" }
          )
          sleep(0.5)
          redo if steps["data"].empty?

          result = OpenAI::Client.new.run_steps.retrieve(
            thread_id: thread_id,
            run_id: run_id,
            id: steps["data"].last["id"],
            parameters: { include: ["step_details.tool_calls[*].file_search.results[*].content"] }
          )
        end

        expect(
          result.dig("step_details", "tool_calls", 0, "file_search", "results", 0, "content", 0,
                     "text")
        ).to include("Activation of the rapidly adapting Pacinian corpuscles")
      end
    end
  end
end
