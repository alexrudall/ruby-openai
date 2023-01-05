require_relative "../../spec_helper"

RSpec.describe OpenAI::ClientApi::Root do
  let(:client) { double(OpenAI::Client) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  subject(:root) { described_class.new(client: client) }

  describe "#completions" do
    context "when the required model parameter is present" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4), model: SecureRandom.hex(4) }
      end

      it "calls json_post on the client with the expected arguments" do
        allow(client).to receive(:json_post).with(path: "/completions",
                                                  parameters: parameters).and_return(ret_val)
        expect(root.completions(parameters: parameters)).to eq(ret_val)
        expect(client).to have_received(:json_post).with(path: "/completions",
                                                         parameters: parameters)
      end
    end

    context "when the required model parameter is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          root.completions(parameters: parameters)
        end.to raise_error OpenAI::MissingRequiredParameterError
      end
    end
  end

  describe "#edits" do
    context "when the required model and instruction parameters are present" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4),
          model: SecureRandom.hex(4),
          instruction: SecureRandom.hex(4) }
      end

      it "calls json_post on the client with the expected arguments" do
        allow(client).to receive(:json_post).with(path: "/edits",
                                                  parameters: parameters).and_return(ret_val)
        expect(root.edits(parameters: parameters)).to eq(ret_val)
        expect(client).to have_received(:json_post).with(path: "/edits", parameters: parameters)
      end
    end

    context "when the required model parameter is missing" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4),
          instruction: SecureRandom.hex(4) }
      end

      it "raises a MissingRequiredParameterError" do
        expect do
          root.edits(parameters: parameters)
        end.to raise_error OpenAI::MissingRequiredParameterError
      end
    end

    context "when the required instruction parameter is missing" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4),
          model: SecureRandom.hex(4) }
      end

      it "raises a MissingRequiredParameterError" do
        expect do
          root.edits(parameters: parameters)
        end.to raise_error OpenAI::MissingRequiredParameterError
      end
    end

    context "when both required input parameters are missing" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) }
      end

      it "raises a MissingRequiredParameterError" do
        expect do
          root.edits(parameters: parameters)
        end.to raise_error OpenAI::MissingRequiredParameterError
      end
    end
  end

  describe "#embeddings" do
    context "when the required model and input parameters are present" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4),
          model: SecureRandom.hex(4),
          input: SecureRandom.hex(4) }
      end

      it "calls json_post on the client with the expected arguments" do
        allow(client).to receive(:json_post).with(path: "/embeddings",
                                                  parameters: parameters).and_return(ret_val)
        expect(root.embeddings(parameters: parameters)).to eq(ret_val)
        expect(client).to have_received(:json_post).with(path: "/embeddings",
                                                         parameters: parameters)
      end
    end

    context "when the required model parameter is missing" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4),
          input: SecureRandom.hex(4) }
      end

      it "raises a MissingRequiredParameterError" do
        expect do
          root.embeddings(parameters: parameters)
        end.to raise_error OpenAI::MissingRequiredParameterError
      end
    end

    context "when the required input parameter is missing" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4),
          model: SecureRandom.hex(4) }
      end

      it "raises a MissingRequiredParameterError" do
        expect do
          root.embeddings(parameters: parameters)
        end.to raise_error OpenAI::MissingRequiredParameterError
      end
    end

    context "when both required input parameters are missing" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) }
      end

      it "raises a MissingRequiredParameterError" do
        expect do
          root.embeddings(parameters: parameters)
        end.to raise_error OpenAI::MissingRequiredParameterError
      end
    end
  end

  describe "#moderations" do
    context "when the required input parameter is present" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4), input: SecureRandom.hex(4) }
      end

      it "calls json_post on the client with the expected arguments" do
        allow(client).to receive(:json_post).with(path: "/moderations",
                                                  parameters: parameters).and_return(ret_val)
        expect(root.moderations(parameters: parameters)).to eq(ret_val)
        expect(client).to have_received(:json_post).with(path: "/moderations",
                                                         parameters: parameters)
      end
    end

    context "when the required input parameter is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          root.moderations(parameters: parameters)
        end.to raise_error OpenAI::MissingRequiredParameterError
      end
    end
  end
end
