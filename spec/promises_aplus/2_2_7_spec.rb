# encoding: UTF-8
require_relative "../spec_helper"
require_relative "../promises_aplus"

dummy = { dummy: "dummy" } # we fulfill or reject with this when we don't intend to test against it
sentinel = { sentinel: "sentinel" } # a sentinel fulfillment value to test for with strict equality
other = { other: "other" } # a value we don't want to be strict equal to

reasons = {
  "`nil`" => nil,
  "`false`" => false,
  "`0`" => 0,
  "an error" => StandardError.new,
  "an error without a stack" => StandardError.new,
  "a date" => Time.now,
  "an object" => Object.new,
  "an always-pending thenable" => Struct.new(:then).new(->(v) {}),
  "a fulfilled promise" => resolved(dummy),
  "a rejected promise" => rejected(dummy)
}

non_functions = {
  "`nil`" => nil,
  "`false`" => false,
  "`5`" => 5,
  "an object" => Object.new,
  "an array containing a callable" => [->(value) { other }]
}

describe "2.2.7: `then` must return a promise: `promise2 = promise1.then(onFulfilled, onRejected)`" do
  include PromisesAplus

  it "is a promise" do
    promise1 = deferred.promise
    promise2 = promise1.then

    promise2.must_be_kind_of Promise
    done!
  end

  describe "2.2.7.1: If either `onFulfilled` or `onRejected` returns a value `x`, run the Promise Resolution Procedure `[[Resolve]](promise2, x)`" do
    it "see separate 3.3 tests" do
      done! and skip
    end
  end

  describe "2.2.7.2: If either `onFulfilled` or `onRejected` throws an exception `e`, `promise2` must be rejected with `e` as the reason." do
    reasons.each do |description, expected_reason|
      describe "The reason is #{description}" do
        PromisesAplus.test_fulfilled(self, dummy) do |promise1, done|
          promise2 = promise1.then ->(value) {
            raise Exception, expected_reason.to_s
          }
          promise2.then nil, ->(reason) {
            reason.to_s.must_equal expected_reason.to_s
            done.call
          }
        end
        PromisesAplus.test_rejected(self, dummy) do |promise1, done|
          promise2 = promise1.then nil, ->(reason) {
            raise Exception, expected_reason.to_s
          }
          promise2.then nil, ->(reason) {
            reason.to_s.must_equal expected_reason.to_s
            done.call
          }
        end
      end
    end
  end

  describe "2.2.7.3: If `onFulfilled` is not a function and `promise1` is fulfilled, `promise2` must be fulfilled with the same value." do
    non_functions.each do |description, non_function|
      describe "`onFulfilled` is #{description}" do
        PromisesAplus.test_fulfilled(self, sentinel) do |promise1, done|
          promise2 = promise1.then(non_function)
          promise2.then ->(value) {
            value.must_equal sentinel
            done.call
          }
        end
      end
    end
  end

  describe "2.2.7.4: If `onRejected` is not a function and `promise1` is rejected, `promise2` must be rejected with the same reason." do
    non_functions.each do |description, non_function|
      describe "`onRejected` is #{description}" do
        PromisesAplus.test_rejected(self, sentinel) do |promise1, done|
          promise2 = promise1.then(nil, non_function)
          promise2.then nil, ->(reason) {
            reason.must_equal sentinel
            done.call
          }
        end
      end
    end
  end
end