require_relative "../spec_helper"

RSpec.describe OpenAI::Client do
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

        it "can be initialized with no arguments and sets values from the global configuration" do
          client = nil
          expect do
            client = OpenAI::Client.new
          end.not_to raise_error
          expect(client.access_token).to eq(global_access_token)
          expect(client.organization_id).to be_nil
          expect(client.api_version).to eq("v1")
        end

        it "allows override of the global access token" do
          client = nil
          expect do
            client = OpenAI::Client.new(access_token: per_client_access_token)
          end.not_to raise_error
          expect(client.access_token).to eq(per_client_access_token)
          expect(client.organization_id).to be_nil
          expect(client.api_version).to eq("v1")
        end

        it "allows setting of an organization_id with the access_token" do
          client = nil
          expect do
            client = OpenAI::Client.new(access_token: per_client_access_token,
                                        organization_id: per_client_organization_id)
          end.not_to raise_error
          expect(client.access_token).to eq(per_client_access_token)
          expect(client.organization_id).to eq(per_client_organization_id)
          expect(client.api_version).to eq("v1")
        end
      end

      context "when the global configuration includes an organization_id" do
        before do
          OpenAI.configure do |config|
            config.access_token = global_access_token
            config.organization_id = global_organization_id
          end
        end

        it "can be initialized with no arguments and sets values from the global configuration" do
          client = nil
          expect do
            client = OpenAI::Client.new
          end.not_to raise_error
          expect(client.access_token).to eq(global_access_token)
          expect(client.organization_id).to eq(global_organization_id)
          expect(client.api_version).to eq("v1")
        end

        it "allows override of the global configuration with a nil organization id" do
          client = nil
          expect do
            client = OpenAI::Client.new(organization_id: nil)
          end.not_to raise_error
          expect(client.access_token).to eq(global_access_token)
          expect(client.organization_id).to be_nil
          expect(client.api_version).to eq("v1")
        end

        it "allows override of the global configuration with a different organization id" do
          client = nil
          expect do
            client = OpenAI::Client.new(organization_id: per_client_organization_id)
          end.not_to raise_error
          expect(client.access_token).to eq(global_access_token)
          expect(client.organization_id).to eq(per_client_organization_id)
          expect(client.api_version).to eq("v1")
        end

        it "allows override of the global configuration with a nil organization id in tandem " \
           "with a per client access token" do
          client = nil
          expect do
            client = OpenAI::Client.new(access_token: per_client_access_token, organization_id: nil)
          end.not_to raise_error
          expect(client.access_token).to eq(per_client_access_token)
          expect(client.organization_id).to be_nil
          expect(client.api_version).to eq("v1")
        end

        it "allows override of the global configuration with a different organization id with " \
           "a per client access token" do
          client = nil
          expect do
            client = OpenAI::Client.new(access_token: per_client_access_token,
                                        organization_id: per_client_organization_id)
          end.not_to raise_error
          expect(client.access_token).to eq(per_client_access_token)
          expect(client.organization_id).to eq(per_client_organization_id)
          expect(client.api_version).to eq("v1")
        end
      end
    end

    context "when the global configuration does not include an access token" do
      it "raises an error when initialized with no arguments" do
        expect do
          OpenAI::Client.new
        end.to raise_error(OpenAI::MissingAccessTokenError)
      end

      it "initializes successfully when passed an access_token" do
        client = nil
        expect do
          client = OpenAI::Client.new(access_token: per_client_access_token)
        end.not_to raise_error
        expect(client.access_token).to eq(per_client_access_token)
        expect(client.organization_id).to be_nil
        expect(client.api_version).to eq("v1")
      end

      it "allows the client to set a per-client organization_id" do
        client = nil
        expect do
          client = OpenAI::Client.new(access_token: per_client_access_token,
                                      organization_id: per_client_organization_id)
        end.not_to raise_error
        expect(client.access_token).to eq(per_client_access_token)
        expect(client.organization_id).to eq(per_client_organization_id)
        expect(client.api_version).to eq("v1")
      end
    end
  end
end
