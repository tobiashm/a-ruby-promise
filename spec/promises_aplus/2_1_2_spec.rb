# encoding: UTF-8
require_relative "../spec_helper"
require_relative "../promises_aplus"

dummy = { dummy: "dummy" }

describe "2.1.2.1: When fulfilled, a promise: must not transition to any other state." do
  include PromisesAplus

  PromisesAplus.test_fulfilled(self, dummy) do |promise, done|
    on_fulfilled_called = false

    promise.then ->(v) {
      onFulfilledCalled = true
    }, ->(r) {
      on_fulfilled_called.must_equal false
      done.call
    }

    short_sleep and done.call
  end

  it "trying to fulfill then immediately reject" do
    d = deferred
    on_fulfilled_called = false
    d.promise.then ->(v) {
      on_fulfilled_called = true
    }, ->(r) {
      on_fulfilled_called.must_equal false
      done!
    }
    d.resolve(dummy)
    d.reject(dummy)

    short_sleep and done!
  end

  it "trying to fulfill then reject, delayed" do
    d = deferred
    on_fulfilled_called = false

    d.promise.then ->(v) {
      on_fulfilled_called = true
    }, ->(r) {
      on_fulfilled_called.must_equal false
      done!
    }

    d.resolve(dummy)
    Thread.new do
      short_sleep
      d.reject(dummy)
    end

    2.times { short_sleep } and done!
  end
end
