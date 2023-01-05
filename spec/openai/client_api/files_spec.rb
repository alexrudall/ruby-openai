require_relative "../../spec_helper"

RSpec.describe OpenAI::ClientApi::Files do
  let(:client) { double(OpenAI::Client) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  subject(:files) { described_class.new(client: client) }

  describe "#list" do
    let(:path_string) { "/files" }

    it "calls get on the client with the expected arguments" do
      allow(client).to receive(:get).with(path: path_string).and_return(ret_val)
      expect(files.list).to eq(ret_val)
      expect(client).to have_received(:get).with(path: path_string)
    end
  end

  describe "#upload" do
    context "when the parameters include a :purpose value" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4), purpose: SecureRandom.hex(4) }
      end

      context "when the parameters include a :file value" do
        let(:filename) { SecureRandom.hex(4) }
        let(:file_instance1) { double(File) }
        let(:file_instance2) { double(File) }
        let(:parameters) do
          { SecureRandom.hex(4).to_sym => SecureRandom.hex(4), purpose: SecureRandom.hex(4),
            file: filename }
        end

        context "when the file can be loaded" do
          let(:merged_parameters) { parameters.merge({ file: file_instance2 }) }

          before do
            allow(File).to receive(:open).with(filename).and_return(file_instance1, file_instance2)
            allow(client).to receive(:multipart_post).with(path: "/files",
                                                           parameters: merged_parameters)
                                                     .and_return(ret_val)
          end

          context "when the file passes JSONL validation" do
            before do
              allow(OpenAI::JsonlValidator).to receive(:validate).with(source: file_instance1)
                                                                 .and_return(true)
            end

            it "runs JSONL validation and passes to the client" do
              val = files.upload(parameters: parameters)
              expect(val).to eq(ret_val)
              expect(OpenAI::JsonlValidator).to have_received(:validate)
                .with(source: file_instance1)
              expect(client).to have_received(:multipart_post).with(path: "/files",
                                                                    parameters: merged_parameters)
            end
          end

          context "when the file does not pass JSONL validation" do
            before do
              allow(OpenAI::JsonlValidator).to receive(:validate).with(source: file_instance1)
                                                                 .and_raise(JSON::ParserError)
            end

            it "runs JSONL validation and does not pass to the client" do
              expect do
                files.upload(parameters: parameters)
              end.to raise_error(JSON::ParserError)
              expect(OpenAI::JsonlValidator).to have_received(:validate)
                .with(source: file_instance1)
              expect(client).not_to have_received(:multipart_post).with(anything)
            end
          end
        end

        context "when the file cannot be loaded" do
          before do
            allow(File).to receive(:open).with(filename).and_raise(Errno::ENOENT)
          end

          after do
            expect(File).to have_received(:open).with(filename)
          end

          it "reraises the underlying error" do
            expect do
              files.upload(parameters: parameters)
            end.to raise_error(Errno::ENOENT)
          end
        end
      end

      context "when the parameters do not include a :file value" do
        it "raises a MissingRequiredParameterError" do
          expect do
            files.upload(parameters: parameters)
          end.to raise_error(OpenAI::MissingRequiredParameterError)
        end
      end
    end

    context "when the parameters do not include a :purpose value" do
      let(:filename) { SecureRandom.hex(4) }
      let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4), file: filename } }

      it "raises an error before calling anything" do
        expect do
          files.upload(parameters: parameters)
        end.to raise_error(OpenAI::MissingRequiredParameterError)
      end
    end

    context "when the parameters do not include either the :file or :purpose values" do
      it "raises an error before calling anything" do
        expect do
          files.upload(parameters: parameters)
        end.to raise_error(OpenAI::MissingRequiredParameterError)
      end
    end
  end

  describe "#retrieve" do
    let(:id) { SecureRandom.hex(4) }
    let(:path_string) { "/files/#{id}" }

    it "calls get on the client with the expected arguments" do
      allow(client).to receive(:get).with(path: path_string).and_return(ret_val)
      expect(files.retrieve(id: id)).to eq(ret_val)
      expect(client).to have_received(:get).with(path: path_string)
    end
  end

  describe "#delete" do
    let(:id) { SecureRandom.hex(4) }
    let(:path_string) { "/files/#{id}" }

    it "calls get on the client with the expected arguments" do
      allow(client).to receive(:delete).with(path: path_string).and_return(ret_val)
      expect(files.delete(id: id)).to eq(ret_val)
      expect(client).to have_received(:delete).with(path: path_string)
    end
  end
end
