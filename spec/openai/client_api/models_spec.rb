require_relative "../../spec_helper"

RSpec.describe OpenAI::ClientApi::Models do
  let(:client) { double(OpenAI::Client) }
  let(:ret_val) { SecureRandom.hex(4) }
  subject(:models) { described_class.new(client: client) }

  describe "#list" do
    it "calls get on the client with the expected argument" do
      allow(client).to receive(:get).with(path: "/models").and_return(ret_val)
      expect(models.list).to eq(ret_val)
      expect(client).to have_received(:get).with(path: "/models")
    end
  end

  describe "#retrieve" do
    let(:id) { SecureRandom.hex(4) }
    let(:path_string) { "/models/#{id}" }

    it "calls get on the client with the expected argument" do
      allow(client).to receive(:get).with(path: path_string).and_return(ret_val)
      expect(models.retrieve(id: id)).to eq(ret_val)
      expect(client).to have_received(:get).with(path: path_string)
    end
  end

  describe "#delete" do
    let(:id) { SecureRandom.hex(4) }
    let(:path_string) { "/models/#{id}" }

    it "calls delete on the client with the expected arguments" do
      allow(client).to receive(:delete).with(path: path_string).and_return(ret_val)
      expect(models.delete(id: id)).to eq(ret_val)
      expect(client).to have_received(:delete).with(path: path_string)
    end
  end
end
