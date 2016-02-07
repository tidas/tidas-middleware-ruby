require 'spec_helper'
require 'tidas'

describe Tidas::SuccessfulResult do
  describe "success?" do
    it "should return true" do
      expect(Tidas::SuccessfulResult.new.success?).to be == true
    end
  end

  
end
