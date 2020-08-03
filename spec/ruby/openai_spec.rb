RSpec.describe Ruby::Openai do
  it "has a version number" do
    require 'byebug'
    expect(Ruby::Openai::VERSION).not_to be nil
  end
end
