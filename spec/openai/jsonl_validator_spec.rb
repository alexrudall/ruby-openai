require_relative "../spec_helper"

RSpec.describe OpenAI::JsonlValidator do
  let(:valid_file) { File.open(Utils.fixture_filename(filename: "puppy.jsonl")) }
  let(:invalid_file) { File.open(Utils.fixture_filename(filename: "errors/missing_quote.jsonl")) }
  let(:png_file) { File.open(Utils.fixture_filename(filename: "image.png")) }

  it "validates a valid JSONL file" do
    expect(described_class.validate(source: valid_file)).to eq(true)
  end

  it "raises an error for a invalid JSONL file" do
    expect { described_class.validate(source: invalid_file) }.to raise_error(JSON::ParserError)
  end

  it "raises an error for a PNG file" do
    expect { described_class.validate(source: png_file) }.to raise_error(JSON::ParserError)
  end
end
