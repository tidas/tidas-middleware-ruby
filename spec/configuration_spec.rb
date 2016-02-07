require 'spec_helper'
require 'tidas'

describe Tidas::Configuration do
  let(:subject) {Tidas::Configuration}

  describe "configure" do
    it "should set server when given one" do
      subject.configure(server:'foo.bar')
      expect(subject.server).to be == 'foo.bar'
    end

    it "should set api_key when given one" do
      subject.configure(api_key:'dffa40f7a0fc98a8fdd7ffff716d6620')
      expect(subject.api_key).to be == 'dffa40f7a0fc98a8fdd7ffff716d6620'
    end

    it "should set application name when given one" do
      subject.configure(application:'Javelin')
      expect(subject.application).to be == 'Javelin'
    end

    it "should set timeout when given one" do
      subject.configure(timeout:2)
      expect(subject.timeout).to be == 2
    end

    context "using ENV variables" do
      before do
        subject.clear_configuration(:server)
        subject.clear_configuration(:api_key)
        subject.clear_configuration(:application)
        subject.clear_configuration(:timeout)

        ENV['tidas_server'] = 'test_server'
        ENV['tidas_api_key'] = 'test_api_key'
        ENV['tidas_application'] = 'test_application'
        ENV['tidas_timeout'] = '5'
      end

      after do
        ENV['tidas_server'] = nil
        ENV['tidas_api_key'] = nil
        ENV['tidas_application'] = nil
        ENV['tidas_timeout'] = nil
      end

      it "should retrieve attributes from ENV if available" do
        subject.configure

        expect(subject.server).to be == 'test_server'
        expect(subject.api_key).to be == 'test_api_key'
        expect(subject.application).to be == 'test_application'
        expect(subject.timeout).to be == 5
      end
    end
  end

  describe "server" do
    before { subject.configure(server: 'test_val')}
    it "should return @server'" do
      expect(subject.server).to be == 'test_val'
    end
  end

  describe "api_key" do
    before { subject.configure(api_key: 'test_val')}
    it "should return @api_key'" do
      expect(subject.api_key).to be == 'test_val'
    end
  end

  describe "application" do
    before { subject.configure(application: 'test_val')}
    it "should return @application'" do
      expect(subject.application).to be == 'test_val'
    end
  end

  describe "timeout" do
    it "should return @timeout' when set" do
      subject.configure(timeout: '2')
      expect(subject.timeout).to be == 2
    end

    it "should return '20' when @timeout is not set" do
      subject.clear_configuration(:timeout)
      expect(subject.timeout).to be == 20
    end
  end

  describe "clear_configuration" do
    before { subject.configure(server: "test_server") }
    it "should clear a named configuration @ivar" do
      expect(subject.server).to be == "test_server"
      subject.clear_configuration(:server)
      expect(subject.server).to be == nil
    end
  end
end
