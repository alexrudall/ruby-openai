RSpec.describe OpenAI::Client do
  it "can be initialized" do
    expect { OpenAI::Client.new }.not_to raise_error
  end

  context "with a prompt and max_tokens", :vcr do
    let(:prompt) { "Once upon a time" }
    let(:max_tokens) { 5 }

    context "with engine: ada" do
      let(:engine) { "ada" }

      it "can make a request to the OpenAI API" do
        VCR.use_cassette("#{engine} #{prompt} #{max_tokens}") do
          response = OpenAI::Client.new.call(engine: engine, prompt: prompt, max_tokens: max_tokens)
          text = JSON.parse(response.body)["choices"].first["text"]
          expect(text.split(" ").empty?).to eq(false)
        end
      end
    end

    context "with engine: babbage" do
      let(:engine) { "babbage" }

      it "can make a request to the OpenAI API" do
        VCR.use_cassette("#{engine} #{prompt} #{max_tokens}") do
          response = OpenAI::Client.new.call(engine: engine, prompt: prompt, max_tokens: max_tokens)
          text = JSON.parse(response.body)["choices"].first["text"]
          expect(text.split(" ").empty?).to eq(false)
        end
      end
    end

    context "with engine: curie" do
      let(:engine) { "curie" }

      it "can make a request to the OpenAI API" do
        VCR.use_cassette("#{engine} #{prompt} #{max_tokens}") do
          response = OpenAI::Client.new.call(engine: engine, prompt: prompt, max_tokens: max_tokens)
          text = JSON.parse(response.body)["choices"].first["text"]
          expect(text.split(" ").empty?).to eq(false)
        end
      end
    end

    context "with engine: davinci" do
      let(:engine) { "davinci" }

      it "can make a request to the OpenAI API" do
        VCR.use_cassette("#{engine} #{prompt} #{max_tokens}") do
          response = OpenAI::Client.new.call(engine: engine, prompt: prompt, max_tokens: max_tokens)
          text = JSON.parse(response.body)["choices"].first["text"]
          expect(text.split(" ").empty?).to eq(false)
        end
      end
    end
  end
end
