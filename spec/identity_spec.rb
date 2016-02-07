require 'spec_helper'
require 'tidas'

describe Tidas::Identity do
  let(:client)   { Tidas::Client }
  let(:subject)  { Tidas::Identity }
  let(:fake_id)  { 'test123' }
  let(:data)     { 'data' }
  let(:identity) { Tidas::Identity.new(id:fake_id, deactivated: false, app_name: 'Javelin', public_key: 'realKeyTrustMe') }

  describe "index" do
    it "should call Tidas::Client.index_identities and then process the response" do
      expect(client).to receive(:index_identities) { true }
      expect(subject).to receive(:process_identity_response).with(true)
      subject.index
    end
  end

  describe "get(id)" do
    it "should call Tidas::Client.get_identity(id) and then process the response" do
      expect(client).to receive(:get_identity).with(fake_id) { true }
      expect(subject).to receive(:process_identity_response).with(true)
      subject.get(fake_id)
    end
  end

  describe "process_identity_response(resp)" do
    describe "when response is successful" do
      let(:resp) { Tidas::SuccessfulResult.new }
      it "should call request_identities(resp)" do
        expect(subject).to receive(:request_identities).with(resp)
        subject.process_identity_response(resp)
      end
    end

    describe "when a response is not successful" do
      let(:resp) { Tidas::ErrorResult.new }
      it "should call return the resp object" do
        expect(subject.process_identity_response(resp).class).to be == Tidas::ErrorResult
      end
    end
  end

  describe "request_identities(resp)" do
    let(:resp) { Object.new }
    describe "when resp contains one identity object" do
      let(:json_input) {{identities:[identity.to_hash_with_key]}.to_json}
      it "should return a Tidas::SuccessfulResult object containing that identity" do
        expect(resp).to receive(:data) {json_input}
        output = subject.request_identities(resp)
        expect(output.class).to be == Tidas::SuccessfulResult
        expect(output.data.class).to be == Tidas::Identity
      end
    end

    describe "when resp contains multiple identity objects" do
      let(:json_input) {{identities:[identity.to_hash_with_key, identity.to_hash_with_key, identity.to_hash_with_key]}.to_json}
      it "should return a Tidas::SuccessfulResult object containing that identity" do
        expect(resp).to receive(:data) {json_input}
        output = subject.request_identities(resp)
        expect(output.class).to be == Tidas::SuccessfulResult
        expect(output.data.class).to be == Array
        expect(output.data[0].class).to be == Tidas::Identity
      end
    end
  end

  describe "enroll(attributes)" do
    describe "when no options hash is passed" do
      it "should call Tidas::Client.enroll(data, <nil>, <nil>)" do
        expect(client).to receive(:enroll).with(data, nil, nil)
        subject.enroll(data:data)
      end
    end

    describe "when an options hash is passed" do
      describe "when passing in a tidas_id" do
        it "should call Tidas::Client.enroll(data, id, <nil>)" do
          expect(client).to receive(:enroll).with(data, fake_id, nil)
          subject.enroll(data:data, options:{tidas_id:fake_id})
        end
      end

      describe "when passing in overwrite as true" do
        it "should call Tidas::Client.enroll(data, nil, true)" do
          expect(client).to receive(:enroll).with(data, nil, true)
          subject.enroll(data:data, options:{overwrite:true})
        end
      end

      describe "when passing in overwrite as anything else" do
        it "should raise an error, explaining that you must only call the option with 'true'" do
          expect{subject.enroll(data:data, options:{overwrite:'noodle'})}.to raise_error(ParameterError)
        end
      end
    end
  end

  describe "validate(attributes)" do
    it "should call Tidas::Client.validate(data, tidas_id)" do
      expect(client).to receive(:validate).with(data, fake_id)
      subject.validate(data:data, tidas_id:fake_id)
    end
  end

  describe "deactivate(attributes)" do
    it "should call Tidas::Client.deactivate(id)" do
      expect(client).to receive(:deactivate).with(fake_id)
      subject.deactivate(tidas_id:fake_id)
    end
  end

  describe "activate(attributes)" do
    it "should call Tidas::Client.activate(id)" do
      expect(client).to receive(:activate).with(fake_id)
      subject.activate(tidas_id:fake_id)
    end
  end
end
