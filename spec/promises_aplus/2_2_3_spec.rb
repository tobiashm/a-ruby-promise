# encoding: UTF-8
require_relative "../spec_helper"
require_relative "../promises_aplus"

dummy = { dummy: "dummy" }
sentinel = { sentinel: "sentinel" }

describe "2.2.3: If `onRejected` is a function," do
  include PromisesAplus

  describe "2.2.3.1: it must be called after `promise` is rejected, with `promise`’s rejection reason as its first argument." do
    PromisesAplus.test_rejected(self, sentinel) do |promise, done|
      promise.then nil, ->(reason) {
        reason.must_equal sentinel
        done.call
      }
    end
  end

  describe "2.2.3.2: it must not be called before `promise` is rejected" do

    it "rejected after a delay" do
      d = deferred
      is_rejected = false
      d.promise.then(nil, ->(r) {
        is_rejected.must_equal true
        done!
      })

      sleep 0.050
      is_rejected = true
      d.reject(dummy)
    end

    it "never rejected" do
      d = deferred
      on_rejected_called = false

      d.promise.then(nil, ->(r) {
        on_rejected_called = true
        done!
      })

      sleep 0.150
      on_rejected_called.must_equal false
      done!
    end
  end

  describe "2.2.3.3: it must not be called more than once." do
    it "already-rejected" do
      times_called = 0

      rejected(dummy).then(nil, ->(r) {
        (times_called += 1).must_equal 1
        done!
      })
    end

    it "trying to reject a pending promise more than once, immediately" do
      d = deferred
      times_called = 0

      d.promise.then(nil, ->(r) {
        (times_called += 1).must_equal 1
        done!
      })

      d.reject(dummy)
      d.reject(dummy)
    end

    it "trying to reject a pending promise more than once, delayed" do
      d = deferred
      times_called = 0

      d.promise.then(nil, ->(r) {
        (times_called += 1).must_equal 1
        done!
      })

      sleep 0.050
      d.reject(dummy)
      d.reject(dummy)
    end

    it "trying to reject a pending promise more than once, immediately then delayed" do
      d = deferred
      times_called = 0

      d.promise.then(nil, ->(r) {
        (times_called += 1).must_equal 1
        done!
      })

      d.reject(dummy)

      sleep 0.050
      d.reject(dummy)
    end

    it "when multiple `then` calls are made, spaced apart in time" do
      d = deferred
      times_called = [0, 0, 0]

      d.promise.then(nil, ->(r) {
        (times_called[0] += 1).must_equal 1
      })

      sleep 0.050
      d.promise.then(nil, ->(r) {
        (times_called[1] += 1).must_equal 1
      })

      sleep 0.050
      d.promise.then(nil, ->(r) {
        (times_called[2] += 1).must_equal 1
        done!
      })

      sleep 0.050
      d.reject(dummy)
    end

    it "when `then` is interleaved with rejection" do
      d = deferred

      times_called = [0, 0]

      d.promise.then(nil, ->(r) {
        (times_called[0] += 1).must_equal 1
      })

      d.reject(dummy)

      d.promise.then(nil, ->(r) {
        (times_called[1] += 1).must_equal 1
        done!
      })
    end
  end
end