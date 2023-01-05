require_relative "../../spec_helper"

RSpec.describe OpenAI::ClientApi::Finetunes do
  let(:client) { double(OpenAI::Client) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  subject(:finetunes) { described_class.new(client: client) }

  describe "#list" do
    let(:path_string) { "/fine-tunes" }

    it "calls get on the client with the expected arguments" do
      allow(client).to receive(:get).with(path: path_string).and_return(ret_val)
      expect(finetunes.list).to eq(ret_val)
      expect(client).to have_received(:get).with(path: path_string)
    end
  end

  describe "#create" do
    context "when the required training_file parameter is present" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4), training_file: SecureRandom.hex(4) }
      end

      it "calls json_post on the client with the expected arguments" do
        allow(client).to receive(:json_post).with(path: "/fine-tunes",
                                                  parameters: parameters).and_return(ret_val)
        expect(finetunes.create(parameters: parameters)).to eq(ret_val)
        expect(client).to have_received(:json_post).with(path: "/fine-tunes",
                                                         parameters: parameters)
      end
    end

    context "when the required training_file parameter is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          finetunes.create(parameters: parameters)
        end.to raise_error OpenAI::MissingRequiredParameterError
      end
    end
  end

  describe "#retrieve" do
    let(:id) { SecureRandom.hex(4) }
    let(:path_string) { "/fine-tunes/#{id}" }

    it "calls get on the client with the expected arguments" do
      allow(client).to receive(:get).with(path: path_string).and_return(ret_val)
      expect(finetunes.retrieve(id: id)).to eq(ret_val)
      expect(client).to have_received(:get).with(path: path_string)
    end
  end

  describe "#cancel" do
    let(:id) { SecureRandom.hex(4) }
    let(:path_string) { "/fine-tunes/#{id}/cancel" }

    it "calls multipart_post on the client with the expected argument" do
      allow(client).to receive(:multipart_post).with(path: path_string).and_return(ret_val)
      expect(finetunes.cancel(id: id)).to eq(ret_val)
      expect(client).to have_received(:multipart_post).with(path: path_string)
    end
  end

  describe "#events" do
    let(:id) { SecureRandom.hex(4) }
    let(:path_string) { "/fine-tunes/#{id}/events" }

    it "calls get on the client with the expected argument" do
      allow(client).to receive(:get).with(path: path_string).and_return(ret_val)
      expect(finetunes.events(id: id)).to eq(ret_val)
      expect(client).to have_received(:get).with(path: path_string)
    end
  end
end
