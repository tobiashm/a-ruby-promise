require_relative "spec_helper"

describe Promise do
  describe "simple fulfillment" do
    it "must call success handler after fulfill" do
      v = nil
      p = Promise.new
      p.then ->(value) { v = value }
      v.must_equal nil
      p.fulfill(42)
      v.must_equal 42
    end
  end
end