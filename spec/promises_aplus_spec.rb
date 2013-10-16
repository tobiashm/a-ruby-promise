require_relative "spec_helper"

# http://promises-aplus.github.io/promises-spec/
# https://github.com/promises-aplus/promises-tests

dummy = { dummy: "dummy" }

describe Promise do
  describe "2.1.2.1: When fulfilled, a promise: must not transition to any other state." do
    it "already-fulfilled" do
      p = resolved(dummy).then ->(v) { pass }, ->(r) { flunk }
      assert_resolved(p)
    end

    it "immediately-fulfilled" do
      d = deferred
      p = d.promise.then ->(v) { pass }, ->(r) { flunk }
      assert_unresolved(p)
      d.fulfill(dummy)
      assert_resolved(p)
    end

    it "eventually-fulfilled" do
      d = deferred
      p = d.promise.then ->(v) { pass }, ->(r) { flunk }
      Thread.new do
        short_sleep
        d.fulfill(dummy)
      end
      assert_unresolved(p)
      eventually { assert_resolved(p) }
    end

    it "trying to fulfill then immediately reject" do
      on_fulfilled_called = false
      Promise.new do
        fulfill(dummy)
        reject(dummy)
      end.then ->(v) { on_fulfilled_called = true }, ->(r) { flunk }
      on_fulfilled_called.must_equal true
    end

    it "trying to fulfill then reject, delayed" do
      on_fulfilled_called = false
      Promise.new do
        Thread.new do
          short_sleep
          fulfill(dummy)
          reject(dummy)
        end
      end.then ->(v) { on_fulfilled_called = true }, ->(r) { flunk }
      on_fulfilled_called.must_equal false
      eventually { on_fulfilled_called.must_equal true }
    end
  end

  describe "2.1.3.1: When rejected, a promise: must not transition to any other state." do
    it "already-rejected" do
      p = rejected(dummy).then ->(v) { flunk }, ->(r) { pass }
      assert_resolved(p)
    end

    it "immediately-rejected" do
      d = deferred
      p = d.promise.then ->(v) { flunk }, ->(r) { pass }
      assert_unresolved(p)
      d.reject(dummy)
      assert_resolved(p)
    end

    it "eventually-rejected" do
      d = deferred
      p = d.promise.then ->(v) { flunk }, ->(r) { pass }
      Thread.new do
        short_sleep
        d.reject(dummy)
      end
      assert_unresolved(p)
      eventually { assert_resolved(p) }
    end

    it "trying to reject then immediately fulfill" do
      on_rejected_called = false
      Promise.new do
        reject(dummy)
        fulfill(dummy)
      end.then ->(v) { flunk }, ->(r) { on_rejected_called = true }
      on_rejected_called.must_equal true
    end

    it "trying to reject then fulfill, delayed" do
      on_rejected_called = false
      Promise.new do
        Thread.new do
          short_sleep
          reject(dummy)
          fulfill(dummy)
        end
      end.then ->(v) { flunk }, ->(r) { on_rejected_called = true }
      on_rejected_called.must_equal false
      eventually { on_rejected_called.must_equal true }
    end
  end

  describe "2.2.1: Both `onFulfilled` and `onRejected` are optional arguments." do
    describe "2.2.1.1: If `onFulfilled` is not a function, it must be ignored." do
      [nil, false, 5, Object.new].each do |non_function|
        it "`onFulfilled` is `#{non_function.inspect}`" do
          p = rejected(dummy).then non_function, ->(r) { pass }
          assert_resolved(p)
        end
      end
    end

    describe "2.2.1.2: If `onRejected` is not a function, it must be ignored." do
      [nil, false, 5, Object.new].each do |non_function|
        it "`onRejected` is `#{non_function.inspect}`" do
          p = resolved(dummy).then ->(v) { pass }, non_function
          assert_resolved(p)
        end
      end
    end
  end
end