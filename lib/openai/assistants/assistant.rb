module OpenAi
  class Assistants
    class Assistant
      def initialize(id:, model:, name: nil, description: nil, instructions: nil, tools: [], file_ids: [], metadata: nil)
        @id = id
        @model = model
        @name = name
        @description = description
        @instructions = instructions
        @tools = tools
        @file_ids = file_ids
        @metadata = metadata
      end
    end
  end
end
