RSpec.describe OpenAI::Tokens do
  context "when string has emoji" do
    let(:string) { "This is an example sentence to try encoding out on! ❤️" }
    let(:ids) { [1212, 318, 281, 1672, 6827, 284, 1949, 21_004, 503, 319, 0, 43_074, 97, 37_929] }

    describe "#encode" do
      subject { described_class.encode(string) }

      it { is_expected.to eq ids }
    end

    describe "#decode" do
      subject { described_class.decode(ids) }

      it { is_expected.to eq string }
    end

    describe "#tokenize" do
      subject { described_class.tokenize(string) }

      let(:tokens) do
        [
          "This",
          " is",
          " an",
          " example",
          " sentence",
          " to",
          " try",
          " encoding",
          " out",
          " on",
          "!",
          " \xE2\x9D",
          "\xA4",
          "️"
        ]
      end

      it { is_expected.to eq tokens }
    end
  end
end
