RSpec.describe OpenAI::Client do
  describe "#chat" do
    context "with messages", :vcr do
      let(:messages) { [{ role: "user", content: "Hello!" }] }
      let(:stream) { false }
      let(:response) do
        OpenAI::Client.new.chat(
          parameters: {
            model: model,
            messages: messages,
            stream: stream
          }
        )
      end
      let(:content) { response.dig("choices", 0, "message", "content") }
      let(:cassette) { "#{model} #{'streamed' if stream} chat".downcase }

      context "with model: gpt-3.5-turbo" do
        let(:model) { "gpt-3.5-turbo" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(content.split.empty?).to eq(false)
          end
        end

        describe "streaming" do
          let(:chunks) { [] }
          let(:stream) do
            proc do |chunk, _bytesize|
              chunks << chunk
            end
          end

          it "succeeds" do
            VCR.use_cassette(cassette) do
              response
              expect(chunks.dig(0, "choices", 0, "index")).to eq(0)
            end
          end

          context "with an object with a call method" do
            let(:cassette) { "#{model} streamed chat without proc".downcase }
            let(:stream) do
              Class.new do
                attr_reader :chunks

                def initialize
                  @chunks = []
                end

                def call(chunk)
                  @chunks << chunk
                end
              end.new
            end

            it "succeeds" do
              VCR.use_cassette(cassette) do
                response
                expect(stream.chunks.dig(0, "choices", 0, "index")).to eq(0)
              end
            end
          end

          context "with an object without a call method" do
            let(:stream) { Object.new }

            it "raises an error" do
              VCR.use_cassette(cassette) do
                expect { response }.to raise_error(ArgumentError)
              end
            end
          end
        end
      end

      context "with model: gpt-3.5-turbo-0301" do
        let(:model) { "gpt-3.5-turbo-0301" }

        it "succeeds" do
          VCR.use_cassette(cassette) do
            expect(content.split.empty?).to eq(false)
          end
        end
      end
    end
  end
end
