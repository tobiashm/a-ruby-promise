# encoding: UTF-8
require_relative "../spec_helper"
require_relative "../promises_aplus"

dummy = { dummy: "dummy" } # we fulfill or reject with this when we don't intend to test against it

describe "2.1.3.1: When rejected, a promise: must not transition to any other state." do
  include PromisesAplus

  PromisesAplus.test_rejected(self, dummy) do |promise, done|
    on_rejected_called = false

    promise.then ->(v) {
      on_rejected_called.must_equal false
      done.call
    }, ->(r) {
      on_rejected_called = true
    }

    short_sleep and done.call
  end

  it "trying to reject then immediately fulfill" do
    d = deferred
    on_rejected_called = false

    d.promise.then ->(v) {
      on_rejected_called.must_equal false
      done!
    }, ->(r) {
      on_rejected_called = true
    }

    d.reject(dummy)
    d.resolve(dummy)
    short_sleep and done!
  end

  it "trying to reject then fulfill, delayed" do
    d = deferred
    on_rejected_called = false

    d.promise.then ->(v) {
      on_rejected_called.must_equal false
      done!
    }, ->(r) {
      on_rejected_called = true
    }

    Thread.new do
      short_sleep
      d.reject(dummy)
      d.resolve(dummy)
    end
    2.times { short_sleep } and done!
  end

  it "trying to reject immediately then fulfill delayed" do
    d = deferred
    on_rejected_called = false

    d.promise.then ->(v) {
      on_rejected_called.must_equal false
      done!
    }, ->(r) {
      on_rejected_called = true
    }

    d.reject(dummy)
    Thread.new do
      short_sleep
      d.resolve(dummy)
    end
    2.times { short_sleep } and done!
  end
end
