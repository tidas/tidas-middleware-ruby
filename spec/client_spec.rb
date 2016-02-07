require 'spec_helper'
require 'tidas'

describe Tidas::Client do
  let(:client) {Tidas::Client}
  let(:response_packager) {Tidas::Utilities::ResponsePackager}

  describe "client" do
    before {Tidas::Configuration.test_configure}
    it "should return a Faraday::Connection object" do
      expect(Tidas::Client.client.class).to be == Faraday::Connection
    end

    it "should always return the same connection object (singleton)" do
      client_instance = Tidas::Client.client
      expect(client_instance.object_id).to be == Tidas::Client.client.object_id
    end
  end

  describe "server" do
    it "should retrieve the server object from Tidas::Configuration" do
      expect(Tidas::Configuration).to receive(:server)
      client.server
    end
  end

  describe "api_key" do
    it "should retrieve the api_key object from Tidas::Configuration" do
      expect(Tidas::Configuration).to receive(:api_key)
      client.api_key
    end
  end

  describe "application" do
    it "should retrieve the application object from Tidas::Configuration" do
      expect(Tidas::Configuration).to receive(:application)
      client.application
    end
  end

  describe "timeout" do
    it "should retrieve the timeout object from Tidas::Configuration" do
      expect(Tidas::Configuration).to receive(:timeout)
      client.timeout
    end
  end

  describe "ping" do
    it "should call wrapped_get('ping')" do
      expect(client).to receive(:wrapped_get).with('ping')
      client.ping
    end
  end

  describe "index_identities" do
    it "should call wrapped_get('identities/index')" do
      expect(client).to receive(:wrapped_get).with('identities/index')
      client.index_identities
    end
  end

  describe "get_identity(id)" do
    let(:tidas_id) { 20 }
    it "should call wrapped_get('identities/index') with an options hash containing an id" do
      expect(client).to receive(:wrapped_get).with('identities/index', {tidas_id: tidas_id})
      client.get_identity(tidas_id)
    end
  end

  describe "enroll(data, id, overwrite)" do
    describe "when body is valid" do
      it "should call wrapped_post('identities/enroll') with a body hash" do
        body = {enrollment_data:'test_data', tidas_id:'test_id', overwrite:true}
        expect(client).to receive(:wrapped_post).with('identities/enroll', body)
        client.enroll(body[:enrollment_data], body[:tidas_id], body[:overwrite])
      end
    end

    describe "when body is empty" do
      it "should still call wrapped_post('identities/enroll') with a body hash" do
        body = {enrollment_data:nil}
        expect(client).to receive(:wrapped_post).with('identities/enroll', body)
        client.enroll(body[:enrollment_data], body[:tidas_id], body[:overwrite])
      end
    end
  end

  describe "validate(data, id)" do
    describe "when data is not valid" do
      it "should return a Tidas::ParameterError explaining that the data was invalid" do
        expect { client.validate("test123", nil) }.to raise_error(Tidas::ParameterError, "Invalid data for request")
      end
    end

    describe "when data is valid" do
      it "should call wrapped_post('identities/validate') with a body hash and data" do
        data_str = Tidas::Utilities::TEST_DATA_STRING
        data_obj = Tidas::Utilities::Unpacker.init_with_blob(data_str)
        body = {validation_data:data_str, tidas_id:'test_id'}
        extracted_data = data_obj.parse[:data_to_sign]

        expect(client).to receive(:wrapped_post).with('identities/validate', body, extracted_data)

        client.validate(body[:validation_data], body[:tidas_id])
      end
    end
  end

  describe "deactivate(id)" do
    it "should call wrapped_post('identities/deactivate') with a body containing a tidas id" do
      body = {tidas_id: 'test123'}
      expect(client).to receive(:wrapped_post).with('identities/deactivate', body)
      client.deactivate(body[:tidas_id])
    end
  end

  describe "activate(id)" do
    it "should call wrapped_post('identities/activate') with a body containing a tidas id" do
      body = {tidas_id: 'test123'}
      expect(client).to receive(:wrapped_post).with('identities/activate', body)
      client.activate(body[:tidas_id])
    end
  end

  describe "wrapped_get(url, extra_params = nil)" do
    describe "when service is reachable, and request does not time out" do
      it "should call ResponsePackager to package the server's response" do
        expect(client).to receive(:get) {true}
        expect(response_packager).to receive(:package_response).with(true)
        client.wrapped_get('test')
      end

      describe "with_extra params" do
        it "should pass those too" do
          expect(client).to receive(:get).with('test', {test: 'test'}) {true}
          expect(response_packager).to receive(:package_response).with(true)
          client.wrapped_get('test', {test: 'test'})
        end
      end
    end

    describe "when the service is reachable and the request does time out" do
      it "should return a Tidas::TimeoutError object explaining the timeout" do
        expect(client).to receive(:get) { raise Faraday::TimeoutError }
        expect(client.wrapped_get('test')).to be == Tidas::TimeoutError
      end
    end

    describe "when the service is unreachable and the request does time out" do
      it "should return a Tidas::Connection object explaining the problem" do
        expect(client.wrapped_get('test')).to be == Tidas::ConnectionError
      end
    end
  end

  describe "wrapped_post(url, body, data = nil)" do
    let(:body) { {body: 'body'} }

    describe "when service is reachable, and request does not time out" do
      it "should call ResponsePackager to package the server's response" do
        expect(client).to receive(:post).with('test', body) {true}
        expect(response_packager).to receive(:package_response).with(true)
        client.wrapped_post('test', body)
      end

      describe "with data" do
        let(:data) { {data: 'data'} }
        it "should pass the data along too" do
          expect(client).to receive(:post).with('test', body) {true}
          expect(response_packager).to receive(:package_response).with(true, data)
          client.wrapped_post('test', body, data)
        end
      end
    end

    describe "when the service is reachable and the request does time out" do
      it "should return a Tidas::TimeoutError object explaining the timeout" do
        expect(client).to receive(:post).with('test', body) { raise Faraday::TimeoutError }
        expect(client.wrapped_post('test', body)).to be == Tidas::TimeoutError
      end
    end

    describe "when the service is unreachable and the request does time out" do
      it "should return a Tidas::Connection object explaining the problem" do
        expect(client.wrapped_post('test', body)).to be == Tidas::ConnectionError
      end
    end
  end

  describe "get(url, extra_params = nil)" do
    
  end

  describe "post(url, body)" do

  end

end
