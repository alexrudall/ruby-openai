module OpenAI
  class Files
    PURPOSES = %w[fine-tune assistants].freeze

    def initialize(client:)
      @client = client
    end

    def list
      @client.get(path: "/files")
    end

    def upload(parameters: {})
      file = get_file(parameters[:file])
      validate(file: file, purpose: parameters[:purpose], file_input: parameters[:file])

      @client.multipart_post(
        path: "/files",
        parameters: parameters.merge(file: file)
      )
    end

    def retrieve(id:)
      @client.get(path: "/files/#{id}")
    end

    def content(id:)
      @client.get(path: "/files/#{id}/content")
    end

    def delete(id:)
      @client.delete(path: "/files/#{id}")
    end

    private

    def validate(file:, purpose:, file_input:)
      raise ArgumentError, "`file` is required" if file.nil?
      unless PURPOSES.include?(purpose)
        raise ArgumentError, "`purpose` must be one of `#{PURPOSES.join(',')}`"
      end

      validate_jsonl(file: file) if file_input.is_a?(String) && file_input.end_with?(".jsonl")
    end

    def validate_jsonl(file:)
      File.open(file) do |open_file|
        open_file.each_line.with_index do |line, index|
          JSON.parse(line)
        rescue JSON::ParserError => e
          raise JSON::ParserError, "#{e.message} - found on line #{index + 1} of #{file}"
        end
      end
    end

    def get_file(file_input)
      case file_input
      when String
        open_file(file_input)
      when File, Tempfile
        file_input
      else
        raise ArgumentError, "Invalid file input"
      end
    end

    def open_file(file_path)
      File.open(file_path)
    rescue Errno::ENOENT => e
      raise StandardError, "File not found: #{e.message}"
    end
  end
end
