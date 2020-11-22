RSpec.describe OpenAI::Client do
  describe "#search" do
    context "with documents and a query", :vcr do
      let(:action) { "search" }
      let(:documents) { %w[washington hospital school] }
      let(:query) { "the president" }
      let(:response) { OpenAI::Client.new.search(engine: engine, documents: documents, query: query) }
      let(:best_match) { JSON.parse(response.body)["data"].max_by { |d| d["score"] }["document"] }
      let(:cassette) { "#{engine} #{action} #{query}".downcase }

      context "with engine: ada" do
        let(:engine) { "ada" }

        it "finds the best match" do
          VCR.use_cassette(cassette) do
            expect(documents[best_match]).to eq("washington")
          end
        end
      end

      context "with engine: babbage" do
        let(:engine) { "babbage" }

        it "finds the best match" do
          VCR.use_cassette(cassette) do
            expect(documents[best_match]).to eq("washington")
          end
        end
      end

      context "with engine: curie" do
        let(:engine) { "curie" }

        it "finds the best match" do
          VCR.use_cassette(cassette) do
            expect(documents[best_match]).to eq("washington")
          end
        end
      end

      context "with engine: davinci" do
        let(:engine) { "davinci" }

        it "finds the best match" do
          VCR.use_cassette(cassette) do
            expect(documents[best_match]).to eq("washington")
          end
        end
      end
    end
  end
end
