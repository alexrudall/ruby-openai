module OpenAI
  class Client
    extend OpenAI::HTTP

    def initialize(access_token: nil, organization_id: nil, uri_base: nil, request_timeout: nil,
                   extra_headers: {})
      OpenAI.configuration.access_token = access_token if access_token
      OpenAI.configuration.organization_id = organization_id if organization_id
      OpenAI.configuration.uri_base = uri_base if uri_base
      OpenAI.configuration.request_timeout = request_timeout if request_timeout
      OpenAI.configuration.extra_headers = extra_headers
    end

    def chat(parameters: {})
      OpenAI::Client.json_post(path: "/chat/completions", parameters: parameters)
    end

    def completions(parameters: {})
      OpenAI::Client.json_post(path: "/completions", parameters: parameters)
    end

    def edits(parameters: {})
      OpenAI::Client.json_post(path: "/edits", parameters: parameters)
    end

    def embeddings(parameters: {})
      OpenAI::Client.json_post(path: "/embeddings", parameters: parameters)
    end

    def files
      @files ||= OpenAI::Files.new
    end

    def finetunes
      @finetunes ||= OpenAI::Finetunes.new
    end

    def images
      @images ||= OpenAI::Images.new
    end

    def models
      @models ||= OpenAI::Models.new
    end

    def moderations(parameters: {})
      OpenAI::Client.json_post(path: "/moderations", parameters: parameters)
    end

    def transcribe(parameters: {})
      OpenAI::Client.multipart_post(path: "/audio/transcriptions", parameters: parameters)
    end

    def translate(parameters: {})
      OpenAI::Client.multipart_post(path: "/audio/translations", parameters: parameters)
    end

    def token_count(parameters: {})
      contents = parameters[:messages]&.map { |message| message[:content] }&.join(" ") || nil
      return 0 if contents.nil?

      if self.class.tiktoken_defined?
        model = parameters[:model] || self.class.default_tiktoken_model
        encoding = Tiktoken.encoding_for_model(model) || Tiktoken.encoding_for_model(self.class.default_tiktoken_model)
        encoding.encode(contents).size
      else
        # https://help.openai.com/en/articles/4936856-what-are-tokens-and-how-to-count-them
        count_by_chars = contents.size / 4.0
        count_by_words = contents.split.size * 4.0 / 3
        estimate = ((count_by_chars + count_by_words)/2.0).round
        [1, estimate].max
      end
    end

    protected

    def self.tiktoken_defined?
      !!(defined? ::Tiktoken)
    end

    def self.default_tiktoken_model
      "gpt-3.5-turbo".freeze
    end
  end
end
