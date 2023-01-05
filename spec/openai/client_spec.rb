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

  describe "#files" do
    let(:access_token) { SecureRandom.hex(4) }
    let(:client) { OpenAI::Client.new(access_token: access_token) }
    let(:interface) { double(OpenAI::ClientApi::Files) }

    it "loads an OpenAI::ClientApi::Files object initialized with the client" do
      allow(OpenAI::ClientApi::Files).to receive(:new).with(client: client).and_return(interface)
      expect(client.files).to eq(interface)
      expect(OpenAI::ClientApi::Files).to have_received(:new).with(client: client)
    end
  end

  describe "#finetunes" do
    let(:access_token) { SecureRandom.hex(4) }
    let(:client) { OpenAI::Client.new(access_token: access_token) }
    let(:interface) { double(OpenAI::ClientApi::Finetunes) }

    it "loads an OpenAI::ClientApi::Finetunes object initialized with the client" do
      allow(OpenAI::ClientApi::Finetunes).to receive(:new).with(client: client)
                                                          .and_return(interface)
      expect(client.finetunes).to eq(interface)
      expect(OpenAI::ClientApi::Finetunes).to have_received(:new).with(client: client)
    end
  end

  describe "#images" do
    let(:access_token) { SecureRandom.hex(4) }
    let(:client) { OpenAI::Client.new(access_token: access_token) }
    let(:interface) { double(OpenAI::ClientApi::Images) }

    it "loads an OpenAI::ClientApi::Images object initialized with the client" do
      allow(OpenAI::ClientApi::Images).to receive(:new).with(client: client).and_return(interface)
      expect(client.images).to eq(interface)
      expect(OpenAI::ClientApi::Images).to have_received(:new).with(client: client)
    end
  end

  describe "#models" do
    let(:access_token) { SecureRandom.hex(4) }
    let(:client) { OpenAI::Client.new(access_token: access_token) }
    let(:interface) { double(OpenAI::ClientApi::Models) }

    it "loads an OpenAI::ClientApi::Models object initialized with the client" do
      allow(OpenAI::ClientApi::Models).to receive(:new).with(client: client).and_return(interface)
      expect(client.models).to eq(interface)
      expect(OpenAI::ClientApi::Models).to have_received(:new).with(client: client)
    end
  end

  describe "#completions" do
    let(:access_token) { SecureRandom.hex(4) }
    let(:client) { OpenAI::Client.new(access_token: access_token) }
    let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
    let(:ret_val) { SecureRandom.hex(4) }
    let(:interface) do
      root = double(OpenAI::ClientApi::Root)
      allow(root).to receive(:completions).with(parameters: parameters).and_return(ret_val)
      root
    end

    it "delegates to a OpenAI::ClientApi::Root object initialized with the client" do
      allow(OpenAI::ClientApi::Root).to receive(:new).with(client: client).and_return(interface)
      expect(client.completions(parameters: parameters)).to eq(ret_val)
      expect(OpenAI::ClientApi::Root).to have_received(:new).with(client: client)
    end
  end

  describe "#edits" do
    let(:access_token) { SecureRandom.hex(4) }
    let(:client) { OpenAI::Client.new(access_token: access_token) }
    let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
    let(:ret_val) { SecureRandom.hex(4) }
    let(:interface) do
      root = double(OpenAI::ClientApi::Root)
      allow(root).to receive(:edits).with(parameters: parameters).and_return(ret_val)
      root
    end

    it "delegates to a OpenAI::ClientApi::Root object initialized with the client" do
      allow(OpenAI::ClientApi::Root).to receive(:new).with(client: client).and_return(interface)
      expect(client.edits(parameters: parameters)).to eq(ret_val)
      expect(OpenAI::ClientApi::Root).to have_received(:new).with(client: client)
    end
  end

  describe "#embeddings" do
    let(:access_token) { SecureRandom.hex(4) }
    let(:client) { OpenAI::Client.new(access_token: access_token) }
    let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
    let(:ret_val) { SecureRandom.hex(4) }
    let(:interface) do
      root = double(OpenAI::ClientApi::Root)
      allow(root).to receive(:embeddings).with(parameters: parameters).and_return(ret_val)
      root
    end

    it "delegates to a OpenAI::ClientApi::Root object initialized with the client" do
      allow(OpenAI::ClientApi::Root).to receive(:new).with(client: client).and_return(interface)
      expect(client.embeddings(parameters: parameters)).to eq(ret_val)
      expect(OpenAI::ClientApi::Root).to have_received(:new).with(client: client)
    end
  end

  describe "#moderations" do
    let(:access_token) { SecureRandom.hex(4) }
    let(:client) { OpenAI::Client.new(access_token: access_token) }
    let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
    let(:ret_val) { SecureRandom.hex(4) }
    let(:interface) do
      root = double(OpenAI::ClientApi::Root)
      allow(root).to receive(:moderations).with(parameters: parameters).and_return(ret_val)
      root
    end

    it "delegates to a OpenAI::ClientApi::Root object initialized with the client" do
      allow(OpenAI::ClientApi::Root).to receive(:new).with(client: client).and_return(interface)
      expect(client.moderations(parameters: parameters)).to eq(ret_val)
      expect(OpenAI::ClientApi::Root).to have_received(:new).with(client: client)
    end
  end

  describe "#get" do
    let(:access_token) { SecureRandom.hex(4) }
    let(:client) { OpenAI::Client.new(access_token: access_token) }
    let(:headers) { client.headers }
    let(:path) { "/#{SecureRandom.hex(4)}" }
    let(:full_path) { "#{described_class::URI_BASE}v1#{path}" }
    let(:ret_val) { SecureRandom.hex(4) }

    before do
      allow(HTTParty).to receive(:get).with(full_path, headers: headers).and_return(ret_val)
    end

    after do
      expect(HTTParty).to have_received(:get).with(full_path, headers: headers)
    end

    it "passes the path and headers to the get method of HTTParty" do
      expect(client.get(path: path)).to eq(ret_val)
    end
  end

  describe "#json_post" do
    let(:access_token) { SecureRandom.hex(4) }
    let(:client) { OpenAI::Client.new(access_token: access_token) }
    let(:headers) { client.headers }
    let(:path) { "/#{SecureRandom.hex(4)}" }
    let(:full_path) { "#{described_class::URI_BASE}v1#{path}" }
    let(:ret_val) { SecureRandom.hex(4) }

    before do
      allow(HTTParty).to receive(:post).with(full_path, headers: headers,
                                                        body: body).and_return(ret_val)
    end

    after do
      expect(HTTParty).to have_received(:post).with(full_path, headers: headers, body: body)
    end

    context "when parameters is not nil" do
      let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
      let(:body) { parameters.to_json }

      it "passes the path, headers (with correct content type) and JSON-ified parameters to " \
         "the post method of HTTParty" do
        expect(client.json_post(path: path, parameters: parameters)).to eq(ret_val)
      end
    end

    context "when parameters is not nil" do
      let(:body) { nil }

      it "passes the path, headers (with correct content type) and nil to the post method of " \
         "HTTParty" do
        expect(client.json_post(path: path, parameters: nil)).to eq(ret_val)
      end
    end
  end

  describe "#multipart_post" do
    let(:access_token) { SecureRandom.hex(4) }
    let(:client) { OpenAI::Client.new(access_token: access_token) }
    let(:headers) { client.headers.merge({ "Content-Type" => "multipart/form-data" }) }
    let(:path) { "/#{SecureRandom.hex(4)}" }
    let(:full_path) { "#{described_class::URI_BASE}v1#{path}" }
    let(:ret_val) { SecureRandom.hex(4) }

    before do
      allow(HTTParty).to receive(:post).with(full_path, headers: headers,
                                                        body: body).and_return(ret_val)
    end

    after do
      expect(HTTParty).to have_received(:post).with(full_path, headers: headers, body: body)
    end

    context "with an explicit parameters argument" do
      let(:parameters) { { SecureRandom.hex(4).to_sym => SecureRandom.hex(4) } }
      let(:body) { parameters }

      it "passes the path, headers (with correct content type), and unaltered parameters to " \
         "the post method of HTTParty" do
        expect(client.multipart_post(path: path, parameters: parameters)).to eq(ret_val)
      end
    end

    context "with no explicit parameters argument" do
      let(:body) { nil }

      it "passes the path, headers  (with correct content type), and nil to the post method of " \
         "HTTParty" do
        expect(client.multipart_post(path: path)).to eq(ret_val)
      end
    end
  end

  describe "#delete" do
    let(:access_token) { SecureRandom.hex(4) }
    let(:client) { OpenAI::Client.new(access_token: access_token) }
    let(:headers) { client.headers }
    let(:path) { "/#{SecureRandom.hex(4)}" }
    let(:full_path) { "#{described_class::URI_BASE}v1#{path}" }
    let(:ret_val) { SecureRandom.hex(4) }

    before do
      allow(HTTParty).to receive(:delete).with(full_path, headers: headers).and_return(ret_val)
    end

    after do
      expect(HTTParty).to have_received(:delete).with(full_path, headers: headers)
    end

    it "passes the path and headers to the delete method of HTTParty" do
      expect(client.delete(path: path)).to eq(ret_val)
    end
  end
end
