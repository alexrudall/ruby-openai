RSpec.describe OpenAI::Client do
  describe "#decisions" do
    let(:client) { OpenAI::Client.new }
    let(:model) { "gpt-6-luna" }
    # Match on the JSON body too, so the specs fail if the parameters are not sent as given.
    let(:vcr_options) { { match_requests_on: %i[method uri body] } }

    describe "#create" do
      context "with a predicate question" do
        let(:cassette) { "decisions create predicate" }

        it "returns the probability that the condition is true" do
          VCR.use_cassette(cassette, vcr_options) do
            response = client.decisions.create(
              parameters: {
                model: model,
                input: "I was charged twice for my order.",
                questions: [
                  {
                    type: "predicate",
                    name: "billing_issue",
                    instructions: "Is this complaint about a billing problem?"
                  }
                ]
              }
            )

            answer = response["answers"].first
            expect(response["model"]).to eq(model)
            expect(answer["type"]).to eq("predicate")
            expect(answer["name"]).to eq("billing_issue")
            expect(answer["probability"]).to be > 0.5
            expect(response.dig("usage", "output_tokens")).to eq(0)
          end
        end
      end

      context "with a choice question" do
        let(:cassette) { "decisions create choice" }

        it "selects one of the supplied values" do
          VCR.use_cassette(cassette, vcr_options) do
            response = client.decisions.create(
              parameters: {
                model: model,
                input: "I was charged twice for my order.",
                questions: [
                  {
                    type: "choice",
                    name: "department",
                    instructions: "Which department should handle this complaint?",
                    choices: [
                      { value: "billing", description: "Payments, invoices, and refunds." },
                      { value: "technical", description: "Problems using the product." },
                      { value: "shipping", description: "Delivery and tracking." },
                      { value: "other", description: "Requests outside these categories." }
                    ]
                  }
                ]
              }
            )

            answer = response["answers"].first
            expect(answer["type"]).to eq("choice")
            expect(answer["choice"]).to eq("billing")
            expect(answer["probabilities"].map { |p| p["value"] })
              .to match_array(%w[billing technical shipping other])
            expect(answer["confidence"]).to be_between(0, 1)
          end
        end
      end

      context "with a score question" do
        let(:cassette) { "decisions create score" }

        it "returns a probability-weighted score over the levels" do
          VCR.use_cassette(cassette, vcr_options) do
            response = client.decisions.create(
              parameters: {
                model: model,
                input: "Export fails in Safari but works in Chrome.",
                questions: [
                  {
                    type: "score",
                    name: "severity",
                    instructions: "How severe is this issue?",
                    levels: [
                      { label: "Cosmetic", description: "Appearance only; no lost functionality." },
                      { label: "Workaround available",
                        description: "A task fails, but another way works." },
                      { label: "Fully blocked", description: "A task fails with no workaround." }
                    ]
                  }
                ]
              }
            )

            answer = response["answers"].first
            expect(answer["type"]).to eq("score")
            expect(answer["score"]).to be_between(0, 2)
            expect(answer["probabilities"].map { |p| p["value"] }).to eq([0, 1, 2])
            expect(answer["probabilities"].map { |p| p["label"] })
              .to eq(["Cosmetic", "Workaround available", "Fully blocked"])
          end
        end
      end

      context "with an image and multiple questions" do
        let(:cassette) { "decisions create image multiple questions" }
        let(:image_url) do
          image = File.binread(File.join(RSPEC_ROOT, "fixtures/files/image.png"))
          "data:image/png;base64,#{[image].pack('m0')}"
        end

        it "answers each question in order" do
          VCR.use_cassette(cassette, vcr_options) do
            response = client.decisions.create(
              parameters: {
                model: model,
                input: [
                  {
                    role: "user",
                    content: [
                      { type: "input_text", text: "Inspect this image." },
                      { type: "input_image", image_url: image_url }
                    ]
                  }
                ],
                questions: [
                  {
                    type: "predicate",
                    name: "contains_text",
                    instructions: "Does the image contain readable text?"
                  },
                  {
                    type: "choice",
                    name: "kind",
                    instructions: "What kind of image is this?",
                    choices: [
                      { value: "photo", description: "A photograph of a real scene." },
                      { value: "graphic", description: "An icon, shape, or illustration." }
                    ]
                  }
                ]
              }
            )

            expect(response["answers"].map { |a| a["name"] }).to eq(%w[contains_text kind])
            expect(response["answers"].first["probability"]).to be_between(0, 1)
            expect(%w[photo graphic]).to include(response["answers"].last["choice"])
          end
        end
      end
    end
  end
end
