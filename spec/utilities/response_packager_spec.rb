require 'spec_helper'
require 'tidas'

describe Tidas::Utilities::ResponsePackager do
  let(:subject) { Tidas::Utilities::ResponsePackager }
  let(:data) { 'valid data' }
  let(:returned_data) { 'valid returned_data' }
  describe "package_response(response, data = nil)" do
    let(:response) { double() }

    describe "if the response is a 500 or 404" do
      it "should return a Tidas::ServerError object when given a 500" do
        expect(response).to receive(:status) {500}
        resp = subject.package_response(response)
        expect(resp).to be == Tidas::InvalidResponse
      end

      it "should return a Tidas::ServerError object when given a 404" do
        expect(response).to receive(:status) {404}
        resp = subject.package_response(response)
        expect(resp).to be == Tidas::InvalidResponse
      end
    end

    describe "if the server returns a non-json/malformed json body" do
      it "should return a Tidas::ServerError object" do
        expect(response).to receive(:status) {200}
        expect(response).to receive(:body) {"dodododododo"}
        resp = subject.package_response(response)
        expect(resp).to be == Tidas::InvalidResponse
      end
    end

    describe "if we successfully parse json from the server" do
      let(:body) { {valid_json: 'totally'}.to_json}
      it "should call handle_result to interpret and package the json" do
        expect(response).to receive(:status) {200}
        expect(response).to receive(:body) {body}
        expect(subject).to receive(:handle_result).with(JSON.parse(body, symbolize_names: true), nil)
        subject.package_response(response)
      end

      it "even with data" do
        expect(response).to receive(:status) {200}
        expect(response).to receive(:body) {body}
        expect(subject).to receive(:handle_result).with(JSON.parse(body, symbolize_names: true), data)
        subject.package_response(response, data)
      end
    end
  end

  describe "handle_result(body)" do
    describe "when returned json type is ':error_result'" do
      let(:body) { {error_result:{errors:["yeah, idk - it just didn't work"]}} }
      it "should return a Tidas::ErrorResult object explaining what went wrong" do
        resp = subject.handle_result(body)
        expect(resp.class).to be == Tidas::ErrorResult
        expect(resp.errors).to be == body[:error_result][:errors]
      end
    end

    describe "when returned json type is ':successful_result'" do
      let(:body) { {successful_result:{message:'worked!'}} }
      describe "if there's no returned data from the server (like identities for packaging)" do
        it "should give a successful result and message" do
          resp = subject.handle_result(body)
          expect(resp.class).to be == Tidas::SuccessfulResult
          expect(resp.message).to be == body[:successful_result][:message]
        end

        it "even when we provide data (like for verification)" do
          body[:data] = data
          resp = subject.handle_result(body, data)
          expect(resp.class).to be == Tidas::SuccessfulResult
          expect(resp.message).to be == body[:successful_result][:message]
          expect(resp.data).to be == data
        end
      end

      describe "when there is returned data from the server (like identities for packaging)" do
        it "should give a successful result and message, and fill that data into the data field" do
          body[:successful_result][:returned_data] = returned_data
          resp = subject.handle_result(body)
          expect(resp.class).to be == Tidas::SuccessfulResult
          expect(resp.message).to be == body[:successful_result][:message]
          expect(resp.data).to be == returned_data
        end
      end

    end
  end
end
