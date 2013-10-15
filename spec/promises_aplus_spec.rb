require_relative "spec_helper"

# http://promises-aplus.github.io/promises-spec/
# https://github.com/promises-aplus/promises-tests

dummy = { dummy: "dummy" }

done = ->(x) { assert true }

describe Promise do
  describe "2.1.2.1: When fulfilled, a promise: must not transition to any other state." do
    test_fulfilled(dummy, ->(promise) {
      on_fulfilled_called = false
      promise.then ->(v) { on_fulfilled_called = true }, ->(r) { on_fulfilled_called.must_equal false }
    })

    it "trying to fulfill then immediately reject" do
      on_fulfilled_called = false
      Promise.new do |fulfill, reject|
        fulfill.call(dummy)
        reject.call(dummy)
      end.then ->(v) { on_fulfilled_called = true }, ->(r) { on_fulfilled_called.must_equal false }
    end

    it "trying to fulfill then reject, delayed" do
      on_fulfilled_called = false
      Promise.new do |fulfill, reject|
        Thread.new do
          short_sleep
          fulfill.call(dummy)
          reject.call(dummy)
        end
      end.then ->(v) { on_fulfilled_called = true }, ->(r) { on_fulfilled_called.must_equal false }
      on_fulfilled_called.must_equal false
      longer_sleep
      on_fulfilled_called.must_equal true
    end
  end

  describe "2.1.3.1: When rejected, a promise: must not transition to any other state." do
    test_rejected(dummy, ->(promise) {
      on_rejected_called = false
      promise.then ->(v) { on_rejected_called.must_equal false }, ->(r) { on_rejected_called = true }
    })

    it "trying to reject then immediately fulfill" do
      on_rejected_called = false
      Promise.new do |fulfill, reject|
        reject.call(dummy)
        fulfill.call(dummy)
      end.then ->(v) { on_rejected_called.must_equal false }, ->(r) { on_rejected_called = true }
    end

    it "trying to reject then fulfill, delayed" do
      on_rejected_called = false
      Promise.new do |fulfill, reject|
        Thread.new do
          short_sleep
          reject.call(dummy)
          fulfill.call(dummy)
        end
      end.then ->(v) { on_rejected_called.must_equal false }, ->(r) { on_rejected_called = true }
      on_rejected_called.must_equal false
      longer_sleep
      on_rejected_called.must_equal true
    end
  end

  describe "2.2.1: Both `onFulfilled` and `onRejected` are optional arguments." do
    describe "2.2.1.1: If `onFulfilled` is not a function, it must be ignored." do
      [nil, false, 5, Object.new].each do |non_function|
        it "`onFulfilled` is `#{non_function.inspect}`" do
          rejected(dummy).then(non_function, done)
        end
      end
    end

    describe "2.2.1.2: If `onRejected` is not a function, it must be ignored." do
      [nil, false, 5, Object.new].each do |non_function|
        it "`onRejected` is `#{non_function.inspect}`" do
          resolved(dummy).then(done, non_function)
        end
      end
    end
  end
end