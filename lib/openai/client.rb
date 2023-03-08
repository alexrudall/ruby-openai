module OpenAI
  class Client < API
    Dir[File.expand_path("../client/*.rb", __FILE__)].each { |f| require f }

    include Audio
    include Completions
    include Edits
    include Files
    include Finetunes
    include Images
    include Models
    include Moderations
  end
end
