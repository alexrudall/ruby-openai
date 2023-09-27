module OpenAI
  module SSE
    def to_completion_json_stream(completion_json_proc:)
      @buffer = ""

      proc do |chunk, _|
        chunk = @buffer + chunk
        @buffer = ""

        blocks = chunk.split("\n\n", -1)

        @buffer = process_blocks(blocks, completion_json_proc)
      end
    end

    private

    def process_blocks(blocks, completion_json_proc)
      buffer = ""

      while blocks.length.positive?
        block = blocks.shift

        if blocks.empty?
          buffer = block unless block.empty?
          break
        end

        process_block(block, completion_json_proc)
      end

      buffer
    end

    def process_block(block, completion_json_proc)
      matches = /([^:]+):\s*(.+)/.match(block)
      return unless matches

      field_name, field_value = matches.captures
      return unless %w[data error].include?(field_name)

      completion_json_proc.call(field_value)
    end
  end
end
