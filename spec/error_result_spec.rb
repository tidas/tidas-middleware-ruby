require 'spec_helper'
require 'tidas'

describe Tidas::ErrorResult do
  let(:result) {Tidas::ErrorResult.new(tidas_id: "id123", errors: %w[test1 test2 test3]) }
  describe "success?" do
    it "should return false" do
      expect(result.success?).to be == false
    end
  end

  describe "errors" do
    it "should return an array of error strings" do
      expect(result.errors.class).to be == Array
      expect(result.errors.length).to be == 3
      expect(result.errors).to be == ["test1", "test2", "test3"]
    end
  end

  describe "to_json" do
    it "should return the error in a digestable json format" do
      expect(result.to_json).to be == %{{"error_result":{"tidas_id":"id123","errors":["test1","test2","test3"]}}}
    end
  end
end
