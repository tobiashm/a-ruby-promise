require_relative "spec_helper"

# Test suite from the `aplus` Python Promise implementation.
# https://github.com/xogeny/aplus#testing

describe Promise do
  describe "Handles the case where the arguments to then are not functions or promises." do
    it "3.2.6.4 pending" do
      d = deferred
      p1 = d.promise
      p2 = p1.then(5)
      d.fulfill(10)
      p1.value.must_equal 10
      p2.state.must_equal :fulfilled
      p2.value.must_equal 10
    end

    it "3.2.6.4 fulfilled" do
      p1 = resolved(10)
      p2 = p1.then(5)
      p1.value.must_equal 10
      p2.state.must_equal :fulfilled
      p2.value.must_equal 10
    end
  end

  describe "Handles the case where the arguments to then are values, not functions or promises." do
    it "3.2.6.5 pending" do
      d = deferred
      p1 = d.promise
      p2 = p1.then(nil, 5)
      d.reject("Error")
      p1.reason.must_equal "Error"
      p2.state.must_equal :rejected
      p2.reason.must_equal "Error"
    end

    it "3.2.6.5 rejected" do
      p1 = rejected("Error")
      p2 = p1.then(nil, 5)
      p1.reason.must_equal "Error"
      p2.state.must_equal :rejected
      p2.reason.must_equal "Error"
    end
  end
end