RSpec.describe OpenAI::Client do
  describe "#vector_stores" do
    let(:vector_store_id) do
      VCR.use_cassette("#{cassette} setup") do
        OpenAI::Client.new.vector_stores.create(parameters: {})["id"]
      end
    end

    describe "#list" do
      let(:cassette) { "vector_stores list" }
      let(:response) do
        OpenAI::Client.new.vector_stores.list(parameters: {})
      end

      it "succeeds" do
        vector_store_id # Need something to list.
        VCR.use_cassette(cassette) do
          expect(response.dig("data", 0, "object")).to eq("vector_store")
        end
      end
    end

    describe "#retrieve" do
      let(:cassette) { "vector_stores retrieve" }
      let(:response) { OpenAI::Client.new.vector_stores.retrieve(id: vector_store_id) }

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("vector_store")
        end
      end
    end

    describe "#create" do
      let(:cassette) { "vector_stores create" }
      let(:response) do
        OpenAI::Client.new.vector_stores.create(parameters: {})
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq "vector_store"
        end
      end
    end

    describe "#modify" do
      let(:cassette) { "vector_stores modify" }
      let(:response) do
        OpenAI::Client.new.vector_stores.modify(
          id: vector_store_id,
          parameters: { metadata: { modified: "true" } }
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq "vector_store"
        end
      end
    end

    describe "#delete" do
      let(:cassette) { "vector_stores delete" }
      let(:response) do
        OpenAI::Client.new.vector_stores.delete(id: vector_store_id)
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq "vector_store.deleted"
        end
      end
    end

    describe "#search" do
      let(:cassette) { "vector_stores search" }
      let(:response) do
        OpenAI::Client.new.vector_stores.search(
          id: vector_store_id,
          parameters: {
            query: "Test search query",
            max_num_results: 5,
            rewrite_query: false
          }
        )
      end

      it "succeeds" do
        VCR.use_cassette(cassette) do
          expect(response["object"]).to eq("vector_store.search_results.page")
        end
      end
    end
  end
end
