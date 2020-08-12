RSpec.describe OpenAI::Client do
  it "can be initialized" do
    expect { OpenAI::Client.new }.not_to raise_error
  end

  it "can make a request to the OpenAI API" do
    client = OpenAI::Client.new
    expect { client.call(prompt: "Once upon a time") }.not_to raise_error
  end
end
