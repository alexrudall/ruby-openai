require_relative "../../spec_helper"

RSpec.describe "Files API" do
  describe "file upload, list, retrieve, and delete", :vcr do
    let(:filename) { "puppy.jsonl" }
    let(:file) { Utils.fixture_filename(filename: filename) }

    let(:upload_cassette) { "files integration" }
    let(:purpose) { "answers" }
    let(:client) { OpenAI::Client.new }
    let(:response) do
      client.files.upload(parameters: { file: file, purpose: purpose })
    end

    it "runs through a basic upload, list, retrieve, and delete" do
      VCR.use_cassette("successful file upload and delete") do

        # Upload a file
        response = client.files.upload(parameters: { file: file, purpose: purpose })
        r = JSON.parse(response.body)
        expect(r["filename"]).to eq(filename)

        # Capture the uploaded file.
        file_id = r["id"]

        # List files and check the uploaded file is included
        response = client.files.list
        r = JSON.parse(response.body)
        expect(r["data"].size).not_to eq(0)
        expect(r["data"].map { |e| e["filename"] }).to include(filename)

        # Retrieve the file that was uploaded
        response = client.files.retrieve(id: file_id)
        r = JSON.parse(response.body)
        expect(r["filename"]).to eq(filename)

        # Give the file time to process if running against the real API
        sleep 2 if ENV["NO_VCR"]

        # Delete the file that was uploaded
        response = client.files.delete(id: file_id)
        r = JSON.parse(response.body)
        expect(r["id"]).to eq(file_id)
        expect(r["deleted"]).to eq(true)
      end
    end
  end
end
