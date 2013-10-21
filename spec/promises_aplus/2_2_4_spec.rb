# encoding: UTF-8
require_relative "../spec_helper"
require_relative "../promises_aplus"

dummy = { dummy: "dummy" }
sentinel = { sentinel: "sentinel" }

describe "2.2.4: `onFulfilled` or `onRejected` must not be called until the execution context stack contains only platform code." do
  include PromisesAplus

  describe "`then` returns before the promise becomes fulfilled or rejected" do
    before { done! and skip "don't know how to delay execution yet" }

    PromisesAplus.test_fulfilled(self, sentinel) do |promise, done|
      thenHasReturned = false

      promise.then ->(v) {
        thenHasReturned.must_equal true
        done.call
      }

      thenHasReturned = true
    end

    PromisesAplus.test_rejected(self, dummy) do |promise, done|
      thenHasReturned = false

      promise.then nil, ->(r) {
        thenHasReturned.must_equal true
        done.call
      }

      thenHasReturned = true
    end
  end

  describe "Clean-stack execution ordering tests (fulfillment case)" do
    before { done! and skip "don't know how to delay execution yet" }

    it "when `onFulfilled` is added immediately before the promise is fulfilled" do
      d = deferred()
      onFulfilledCalled = false

      d.promise.then ->(v) do
        onFulfilledCalled = true
      end

      d.resolve(dummy)

      onFulfilledCalled.must_equal false
      done!
    end

    it "when `onFulfilled` is added immediately after the promise is fulfilled" do
      d = deferred()
      onFulfilledCalled = false

      d.resolve(dummy)

      d.promise.then ->(v) do
        onFulfilledCalled = true
      end

      onFulfilledCalled.must_equal false
      done!
    end

    it "when one `onFulfilled` is added inside another `onFulfilled`" do
      promise = resolved()
      firstOnFulfilledFinished = false

      promise.then ->(v) do
        promise.then ->(v) do
          firstOnFulfilledFinished.must_equal true
          done!
        end
        firstOnFulfilledFinished = true
      end
    end

    it "when `onFulfilled` is added inside an `onRejected`" do
      promise = rejected()
      promise2 = resolved()
      firstOnRejectedFinished = false

      promise.then nil, ->(r) do
        promise2.then ->(v) do
          firstOnRejectedFinished.must_equal true
          done!
        end
        firstOnRejectedFinished = true
      end
    end

    it "when the promise is fulfilled asynchronously" do
      d = deferred()
      firstStackFinished = false

      f = Fiber.new do
        d.resolve(dummy)
        firstStackFinished = true
      end

      d.promise.then ->(v) do
        firstStackFinished.must_equal true
        done!
      end

      f.resume
    end
  end

  describe "Clean-stack execution ordering tests (rejection case)" do
    before { done! and skip "don't know how to delay execution yet" }

    it "when `onRejected` is added immediately before the promise is rejected" do
      d = deferred()
      onRejectedCalled = false

      d.promise.then nil, ->(r) do
        onRejectedCalled = true
      end

      d.reject(dummy)

      onRejectedCalled.must_equal false
      done!
    end

    it "when `onRejected` is added immediately after the promise is rejected" do
      d = deferred()
      onRejectedCalled = false

      d.reject(dummy)

      d.promise.then nil, ->(r) do
        onRejectedCalled = true
      end

      onRejectedCalled.must_equal false
      done!
    end

    it "when `onRejected` is added inside an `onFulfilled`" do
      promise = resolved()
      promise2 = rejected()
      firstOnFulfilledFinished = false

      promise.then ->(v) do
        promise2.then nil, ->(r) do
          firstOnFulfilledFinished.must_equal true
          done!
        end
        firstOnFulfilledFinished = true
      end
    end

    it "when one `onRejected` is added inside another `onRejected`" do
      promise = rejected()
      firstOnRejectedFinished = false

      promise.then nil, ->(r) do
        promise.then nil, ->(r) do
          firstOnRejectedFinished.must_equal true
          done!
        end
        firstOnRejectedFinished = true
      end
    end

    it "when the promise is rejected asynchronously" do
      d = deferred()
      firstStackFinished = false

      f = Fiber.new do
        d.reject(dummy)
        firstStackFinished = true
      end

      d.promise.then nil, ->(r) do
        firstStackFinished.must_equal true
        done!
      end

      f.resume
    end
  end
end