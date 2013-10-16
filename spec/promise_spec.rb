require_relative "spec_helper"

def timeout_promise(promise, timeout_in_seconds)
  Promise.new do
    promise.then method(:fulfill)
    Thread.new do
      sleep timeout_in_seconds
      reject "Timeout reached"
    end
  end
end

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

  describe "timeout" do
    it "fulfills quickly" do
      p1 = Promise.new
      p2 = timeout_promise(p1, 0.05)
      p1.fulfill "ok"
      p2.state.must_equal :fulfilled
      p2_value = nil
      p2.then ->(value) { p2_value = value }
      p2_value.must_equal "ok"
    end

    it "rejects after some time" do
      p1 = Promise.new
      p2 = timeout_promise(p1, 0.05)
      sleep 0.1
      p1.fulfill "ok"
      p2.state.must_equal :rejected
      p2_reason = nil
      p2.then nil, ->(reason) { p2_reason = reason }
      p2_reason.must_equal "Timeout reached"
    end
  end
end