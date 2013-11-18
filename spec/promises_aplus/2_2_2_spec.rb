# encoding: UTF-8
require_relative "../spec_helper"
require_relative "../promises_aplus"

dummy = { dummy: "dummy" } #  we fulfill or reject with this when we don't intend to test against it
sentinel = { sentinel: "sentinel" } # a sentinel fulfillment value to test for with strict equality

describe "2.2.2: If `onFulfilled` is a function," do
  include PromisesAplus

  describe "2.2.2.1: it must be called after `promise` is fulfilled, with `promise`’s fulfillment value as its first argument." do
    PromisesAplus.test_fulfilled(self, sentinel) do |promise, done|
      promise.then ->(value) {
        value.must_equal sentinel
        done.call
      }
    end
  end

  describe "2.2.2.2: it must not be called before `promise` is fulfilled" do

    it "fulfilled after a delay" do
      d = deferred
      is_fulfilled = false
      d.promise.then ->(v) {
        assert_equal true, is_fulfilled
        done!
      }

      Thread.new do
        short_sleep
        is_fulfilled = true
        d.resolve(dummy)
      end
    end

    it "never fulfilled" do
      d = deferred
      on_fulfilled_called = false

      d.promise.then ->(v) {
        on_fulfilled_called = true
        done!
      }

      done = method(:done!)
      Thread.new do
        3.times { short_sleep }
        assert_equal false, on_fulfilled_called
        done.call
      end
    end
  end

  describe "2.2.2.3: it must not be called more than once." do
    it "already-fulfilled" do
      times_called = 0

      resolved(dummy).then(->(v) {
        (times_called += 1).must_equal 1
        done!
      })
    end

    it "trying to fulfill a pending promise more than once, immediately" do
      d = deferred
      times_called = 0

      d.promise.then(->(v) {
        (times_called += 1).must_equal 1
        done!
      })

      d.resolve(dummy)
      d.resolve(dummy)
    end

    it "trying to fulfill a pending promise more than once, delayed" do
      d = deferred
      times_called = 0

      d.promise.then(->(v) {
        assert_equal 1, (times_called += 1)
        done!
      })

      Thread.new do
        short_sleep
        d.resolve(dummy)
        d.resolve(dummy)
      end
    end

    it "trying to fulfill a pending promise more than once, immediately then delayed" do
      d = deferred
      times_called = 0

      d.promise.then(->(v) {
        (times_called += 1).must_equal 1
        done!
      })

      d.resolve(dummy)
      Thread.new do
        short_sleep
        d.resolve(dummy)
      end
    end

    it "when multiple `then` calls are made, spaced apart in time" do
      d = deferred
      times_called = [0, 0, 0]

      d.promise.then(->(v) {
        assert_equal 1, (times_called[0] += 1)
      })

      Thread.new do
        short_sleep
        d.promise.then(->(v) {
          assert_equal 1, (times_called[1] += 1)
        })
      end

      Thread.new do
        2.times { short_sleep }
        d.promise.then(->(v) {
          assert_equal 1, (times_called[2] += 1)
          done!
        })
      end

      Thread.new do
        3.times { short_sleep }
        d.resolve(dummy)
      end
    end

    it "when `then` is interleaved with fulfillment" do
      d = deferred
      times_called = [0, 0]

      d.promise.then(->(v) {
        (times_called[0] += 1).must_equal 1
      })

      d.resolve(dummy)

      d.promise.then(->(v) {
        (times_called[1] += 1).must_equal 1
        done!
      })
    end
  end
end