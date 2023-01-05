require_relative "../spec_helper"

RSpec.describe OpenAI::HeadersFactory do
  describe ".initialize" do
    let(:per_client_access_token) { SecureRandom.hex(4) }
    let(:per_client_organization_id) { SecureRandom.hex(4) }

    context "when the global configuration includes an access token" do
      let(:global_access_token) { SecureRandom.hex(4) }
      let(:global_organization_id) { SecureRandom.hex(4) }

      context "when the global configuration does not include an organization_id" do
        before do
          OpenAI.configure do |config|
            config.access_token = global_access_token
          end
        end

        it "uses the global access_token when passed nil" do
          hf = nil
          expect do
            hf = described_class.new(access_token: nil,
                                     organization_id: described_class::NULL_ORGANIZATION_ID)
          end.not_to raise_error
          expect(hf.access_token).to eq(global_access_token)
          expect(hf.organization_id).to be_nil
        end

        it "allows override of the global access token" do
          hf = nil
          expect do
            hf = described_class.new(access_token: per_client_access_token,
                                     organization_id: described_class::NULL_ORGANIZATION_ID)
          end.not_to raise_error
          expect(hf.access_token).to eq(per_client_access_token)
          expect(hf.organization_id).to be_nil
        end

        it "allows setting of an organization_id with the access_token" do
          hf = nil
          expect do
            hf = described_class.new(access_token: per_client_access_token,
                                     organization_id: per_client_organization_id)
          end.not_to raise_error
          expect(hf.access_token).to eq(per_client_access_token)
          expect(hf.organization_id).to eq(per_client_organization_id)
        end
      end

      context "when the global configuration includes an organization_id" do
        before do
          OpenAI.configure do |config|
            config.access_token = global_access_token
            config.organization_id = global_organization_id
          end
        end

        it "allows override of the global configuration with a nil organization id in tandem " \
           "with a per client access token" do
          hf = nil
          expect do
            hf = described_class.new(access_token: per_client_access_token, organization_id: nil)
          end.not_to raise_error
          expect(hf.access_token).to eq(per_client_access_token)
          expect(hf.organization_id).to be_nil
        end

        it "allows override of the global configuration with a different organization id with " \
           "a per client access token" do
          hf = nil
          expect do
            hf = described_class.new(access_token: per_client_access_token,
                                     organization_id: per_client_organization_id)
          end.not_to raise_error
          expect(hf.access_token).to eq(per_client_access_token)
          expect(hf.organization_id).to eq(per_client_organization_id)
        end
      end
    end

    context "when the global configuration does not include an access token" do
      it "raises an error when initialized with no arguments" do
        expect do
          described_class.new(access_token: nil,
                              organization_id: described_class::NULL_ORGANIZATION_ID)
        end.to raise_error(OpenAI::MissingAccessTokenError)
      end

      it "initializes successfully when passed an access_token and a null object organization_id" do
        hf = nil
        expect do
          hf = described_class.new(access_token: per_client_access_token,
                                   organization_id: described_class::NULL_ORGANIZATION_ID)
        end.not_to raise_error
        expect(hf.access_token).to eq(per_client_access_token)
        expect(hf.organization_id).to be_nil
      end

      it "initializes successfully when passed an access_token and a nil organization_id" do
        hf = nil
        expect do
          hf = described_class.new(access_token: per_client_access_token,
                                   organization_id: nil)
        end.not_to raise_error
        expect(hf.access_token).to eq(per_client_access_token)
        expect(hf.organization_id).to be_nil
      end

      it "allows the client to set a per-client organization_id" do
        hf = nil
        expect do
          hf = described_class.new(access_token: per_client_access_token,
                                   organization_id: per_client_organization_id)
        end.not_to raise_error
        expect(hf.access_token).to eq(per_client_access_token)
        expect(hf.organization_id).to eq(per_client_organization_id)
      end
    end
  end

  describe "#headers" do
    let(:access_token) { SecureRandom.hex(4) }

    context "when called with no arguments" do
      subject(:headers) do
        described_class.new(access_token: access_token, organization_id: organization_id).headers
      end

      context "when the organization_id is nil" do
        let(:organization_id) { described_class::NULL_ORGANIZATION_ID }

        it "returns the expected headers" do
          expect(headers.size).to eq(2)
          expect(headers["Content-Type"]).to eq("application/json")
          expect(headers["Authorization"]).to eq("Bearer #{access_token}")
        end
      end

      context "when the organization_id is not nil" do
        let(:organization_id) { SecureRandom.hex(4) }

        it "returns the expected headers" do
          expect(headers.size).to eq(3)
          expect(headers["Content-Type"]).to eq("application/json")
          expect(headers["Authorization"]).to eq("Bearer #{access_token}")
          expect(headers["OpenAI-Organization"]).to eq(organization_id)
        end
      end
    end

    context "when called with an explicit content_type" do
      let(:content_type) { SecureRandom.hex(5) }
      subject(:headers) do
        described_class.new(access_token: access_token,
                            organization_id: organization_id).headers(content_type: content_type)
      end

      context "when the organization_id is nil" do
        let(:organization_id) { described_class::NULL_ORGANIZATION_ID }

        it "returns the expected headers" do
          expect(headers.size).to eq(2)
          expect(headers["Content-Type"]).to eq(content_type)
          expect(headers["Authorization"]).to eq("Bearer #{access_token}")
        end
      end

      context "when the organization_id is not nil" do
        let(:organization_id) { SecureRandom.hex(4) }

        it "returns the expected headers" do
          expect(headers.size).to eq(3)
          expect(headers["Content-Type"]).to eq(content_type)
          expect(headers["Authorization"]).to eq("Bearer #{access_token}")
          expect(headers["OpenAI-Organization"]).to eq(organization_id)
        end
      end
    end
  end
end
