RSpec.describe OpenAI::Client do
  it "can be initialized" do
    expect { OpenAI::Client.new }.not_to raise_error
  end
end
