require_relative "../../spec_helper"

RSpec.describe OpenAI::ClientApi::Images do
  let(:client) { double(OpenAI::Client) }
  let(:ret_val) { SecureRandom.hex(4) }
  let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
  subject(:images) { described_class.new(client: client) }

  describe "#generate" do
    let(:path_string) { "/images/generations" }

    context "when the required prompt parameter is present" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4), prompt: SecureRandom.hex(4) }
      end

      it "calls json_post on the client with the expected arguments" do
        allow(client).to receive(:json_post).with(path: path_string,
                                                  parameters: parameters).and_return(ret_val)
        expect(images.generate(parameters: parameters)).to eq(ret_val)
        expect(client).to have_received(:json_post).with(path: path_string,
                                                         parameters: parameters)
      end
    end

    context "when the required prompt parameter is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          images.generate(parameters: parameters)
        end.to raise_error OpenAI::MissingRequiredParameterError
      end
    end
  end

  describe "#edit" do
    let(:path_string) { "/images/edits" }

    context "when the required prompt parameter is present" do
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4), prompt: SecureRandom.hex(4) }
      end

      context "when the required image parameter is present" do
        let(:image_filename) { SecureRandom.hex(4) }
        let(:parameters) do
          { SecureRandom.hex(4).to_sym => SecureRandom.hex(4), prompt: SecureRandom.hex(4),
            image: image_filename }
        end

        context "when the image file can be loaded" do
          let(:image_file) { double(File) }

          before do
            allow(File).to receive(:open).with(image_filename).and_return(image_file)
          end

          after do
            expect(File).to have_received(:open).with(image_filename)
          end

          context "when the optional mask parameter is not present" do
            let(:merged_parameters) do
              parameters.merge({ image: image_file })
            end

            it "calls multipart_post on the client with the expected arguments" do
              allow(client).to receive(:multipart_post).with(path: path_string,
                                                             parameters: merged_parameters)
                                                       .and_return(ret_val)
              expect(images.edit(parameters: parameters)).to eq(ret_val)
              expect(client).to have_received(:multipart_post).with(path: path_string,
                                                                    parameters: merged_parameters)
            end
          end

          context "when the optional mask parameter is present" do
            let(:mask_filename) { SecureRandom.hex(4) }
            let(:parameters) do
              { SecureRandom.hex(4).to_sym => SecureRandom.hex(4), prompt: SecureRandom.hex(4),
                image: image_filename, mask: mask_filename }
            end

            context "when the mask file can be loaded" do
              let(:mask_file) { double(File) }
              let(:merged_parameters) do
                parameters.merge({ image: image_file, mask: mask_file })
              end

              before do
                allow(File).to receive(:open).with(mask_filename).and_return(mask_file)
              end

              after do
                expect(File).to have_received(:open).with(mask_filename)
              end

              it "calls multipart_post on the client with the expected arguments" do
                allow(client).to receive(:multipart_post).with(path: path_string,
                                                               parameters: merged_parameters)
                                                         .and_return(ret_val)
                expect(images.edit(parameters: parameters)).to eq(ret_val)
                expect(client).to have_received(:multipart_post).with(path: path_string,
                                                                      parameters: merged_parameters)
              end
            end

            context "when the image file cannot be loaded" do
              before do
                allow(File).to receive(:open).with(mask_filename).and_raise(Errno::ENOENT)
              end

              after do
                expect(File).to have_received(:open).with(mask_filename)
              end

              it "reraises the underlying error" do
                expect do
                  images.edit(parameters: parameters)
                end.to raise_error(Errno::ENOENT)
              end
            end
          end
        end

        context "when the image file cannot be loaded" do
          before do
            allow(File).to receive(:open).with(image_filename).and_raise(Errno::ENOENT)
          end

          after do
            expect(File).to have_received(:open).with(image_filename)
          end

          it "reraises the underlying error" do
            expect do
              images.edit(parameters: parameters)
            end.to raise_error(Errno::ENOENT)
          end
        end
      end

      context "when the required image parameter is missing" do
        it "raises a MissingRequiredParameterError" do
          expect do
            images.edit(parameters: parameters)
          end.to raise_error OpenAI::MissingRequiredParameterError
        end
      end
    end

    context "when the required prompt parameter is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          images.generate(parameters: parameters)
        end.to raise_error OpenAI::MissingRequiredParameterError
      end
    end
  end

  describe "#variations" do
    let(:path_string) { "/images/variations" }

    context "when the required image parameter is present" do
      let(:image_filename) { SecureRandom.hex(4) }
      let(:parameters) do
        { SecureRandom.hex(4).to_sym => SecureRandom.hex(4),
          image: image_filename }
      end

      context "when the image file can be loaded" do
        let(:image_file) { double(File) }

        before do
          allow(File).to receive(:open).with(image_filename).and_return(image_file)
        end

        after do
          expect(File).to have_received(:open).with(image_filename)
        end

        context "when the optional mask parameter is not present" do
          let(:merged_parameters) do
            parameters.merge({ image: image_file })
          end

          it "calls multipart_post on the client with the expected arguments" do
            allow(client).to receive(:multipart_post).with(path: path_string,
                                                           parameters: merged_parameters)
                                                     .and_return(ret_val)
            expect(images.variations(parameters: parameters)).to eq(ret_val)
            expect(client).to have_received(:multipart_post).with(path: path_string,
                                                                  parameters: merged_parameters)
          end
        end

        context "when the optional mask parameter is present" do
          let(:mask_filename) { SecureRandom.hex(4) }
          let(:parameters) do
            { SecureRandom.hex(4).to_sym => SecureRandom.hex(4),
              image: image_filename, mask: mask_filename }
          end

          context "when the mask file can be loaded" do
            let(:mask_file) { double(File) }
            let(:merged_parameters) do
              parameters.merge({ image: image_file, mask: mask_file })
            end

            before do
              allow(File).to receive(:open).with(mask_filename).and_return(mask_file)
            end

            after do
              expect(File).to have_received(:open).with(mask_filename)
            end

            it "calls multipart_post on the client with the expected arguments" do
              allow(client).to receive(:multipart_post).with(path: path_string,
                                                             parameters: merged_parameters)
                                                       .and_return(ret_val)
              expect(images.variations(parameters: parameters)).to eq(ret_val)
              expect(client).to have_received(:multipart_post).with(path: path_string,
                                                                    parameters: merged_parameters)
            end
          end

          context "when the image file cannot be loaded" do
            before do
              allow(File).to receive(:open).with(mask_filename).and_raise(Errno::ENOENT)
            end

            after do
              expect(File).to have_received(:open).with(mask_filename)
            end

            it "reraises the underlying error" do
              expect do
                images.variations(parameters: parameters)
              end.to raise_error(Errno::ENOENT)
            end
          end
        end
      end

      context "when the image file cannot be loaded" do
        before do
          allow(File).to receive(:open).with(image_filename).and_raise(Errno::ENOENT)
        end

        after do
          expect(File).to have_received(:open).with(image_filename)
        end

        it "reraises the underlying error" do
          expect do
            images.variations(parameters: parameters)
          end.to raise_error(Errno::ENOENT)
        end
      end
    end

    context "when the required image parameter is missing" do
      it "raises a MissingRequiredParameterError" do
        expect do
          images.edit(parameters: parameters)
        end.to raise_error OpenAI::MissingRequiredParameterError
      end
    end
  end
end
