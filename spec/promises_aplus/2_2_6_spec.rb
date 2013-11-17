# encoding: UTF-8
require_relative "../spec_helper"
require_relative "../promises_aplus"

dummy = { dummy: "dummy" } # we fulfill or reject with this when we don't intend to test against it
other = { other: "other" } # a value we don't want to be strict equal to
sentinel = { sentinel: "sentinel" } # a sentinel fulfillment value to test for with strict equality
sentinel2 = { sentinel2: "sentinel2" }
sentinel3 = { sentinel3: "sentinel3" }

CallbackAggregator = Struct.new(:times, :ultimate_callback) do
  def call
    @so_far = (@so_far || 0) + 1
    ultimate_callback.call if @so_far == times
  end
end

describe "2.2.6: `then` may be called multiple times on the same promise." do
  include PromisesAplus

  describe "2.2.6.1: If/when `promise` is fulfilled, all respective `onFulfilled` callbacks must execute in the order of their originating calls to `then`." do
    describe "multiple boring fulfillment handlers" do
      PromisesAplus.test_fulfilled(self, sentinel) do |promise, done|
        handler1 = Minitest::Mock.new.expect(:call, nil, [sentinel])
        handler2 = Minitest::Mock.new.expect(:call, nil, [sentinel])
        handler3 = Minitest::Mock.new.expect(:call, nil, [sentinel])
        spy = Minitest::Mock.new

        promise.then(handler1, spy)
        promise.then(handler2, spy)
        promise.then(handler3, spy)

        promise.then ->(value) {
          value.must_equal sentinel
          [handler1, handler2, handler3, spy].each(&:verify)
          done.call
        }
      end
    end

    describe "multiple fulfillment handlers, one of which throws" do
      PromisesAplus.test_fulfilled(self, sentinel) do |promise, done|
        handler1 = Minitest::Mock.new.expect(:call, nil, [sentinel])
        handler2 = Minitest::Mock.new.expect(:call, nil, [sentinel])
        handler3 = Minitest::Mock.new.expect(:call, nil, [sentinel])
        spy = Minitest::Mock.new

        promise.then(handler1, spy)
        promise.then(->(value) { handler2.call(value); throw(other) }, spy)
        promise.then(handler3, spy)

        promise.then ->(value) {
          value.must_equal sentinel
          [handler1, handler2, handler3, spy].each(&:verify)
          done.call
        }
      end
    end

    describe "results in multiple branching chains with their own fulfillment values" do
      PromisesAplus.test_fulfilled(self, sentinel) do |promise, done|
        semi_done = CallbackAggregator.new(3, done)

        promise.then(->(value) {
          sentinel
        }).then(->(value) {
          value.must_equal sentinel
          semi_done.call
        })

        promise.then(->(value) {
          raise Exception.new(sentinel2)
        }).then(nil, ->(reason) {
          reason.to_s.must_equal sentinel2.to_s
          semi_done.call
        })

        promise.then(->(value) {
          sentinel3
        }).then(->(value) {
          value.must_equal sentinel3
          semi_done.call
        })
      end
    end

    describe "`onFulfilled` handlers are called in the original order" do
      PromisesAplus.test_fulfilled(self, dummy) do |promise, done|
        handler1 = Minitest::Mock.new.expect(:call, 1, [dummy])
        handler2 = Minitest::Mock.new.expect(:call, 2, [dummy])
        handler3 = Minitest::Mock.new.expect(:call, 3, [dummy])
        sequence = Minitest::Mock.new.expect(:call, nil, [1]).expect(:call, nil, [2]).expect(:call, nil, [3])

        promise.then(handler1).then(sequence)
        promise.then(handler2).then(sequence)
        promise.then(handler3).then(sequence)

        promise.then ->(value) {
          value.must_equal dummy
          [handler1, handler2, handler3, sequence].each(&:verify)
          done.call
        }
      end

      describe "even when one handler is added inside another handler" do
        PromisesAplus.test_fulfilled(self, dummy) do |promise, done|
          handler1 = Minitest::Mock.new.expect(:call, 1, [dummy])
          handler2 = Minitest::Mock.new.expect(:call, 2, [dummy])
          handler3 = Minitest::Mock.new.expect(:call, 3, [dummy])
          sequence = Minitest::Mock.new.expect(:call, nil, [1]).expect(:call, nil, [2]).expect(:call, nil, [3])

          # TODO: The JavaScript spec adds handler3 inside this handler,
          # but since we don't have the delayed execution of handlers, we can't do that!
          promise.then ->(value) {
            sequence.call(handler1.call(value))
            promise.then(handler2).then(sequence)
          }
          promise.then(handler3).then(sequence)

          promise.then ->(value) {
            value.must_equal dummy
            [handler1, handler2, handler3, sequence].each(&:verify)
            done.call
          }
        end
      end
    end
  end

  describe "2.2.6.2: If/when `promise` is rejected, all respective `onRejected` callbacks must execute in the order of their originating calls to `then`." do
    describe "multiple boring rejection handlers" do
      PromisesAplus.test_rejected(self, sentinel) do |promise, done|
        handler1 = Minitest::Mock.new.expect(:call, nil, [sentinel])
        handler2 = Minitest::Mock.new.expect(:call, nil, [sentinel])
        handler3 = Minitest::Mock.new.expect(:call, nil, [sentinel])
        spy = Minitest::Mock.new

        promise.then(spy, handler1)
        promise.then(spy, handler2)
        promise.then(spy, handler3)

        promise.then nil, ->(reason) {
          reason.must_equal sentinel
          [handler1, handler2, handler3, spy].each(&:verify)
          done.call
        }
      end
    end

    describe "multiple rejection handlers, one of which throws" do
      PromisesAplus.test_rejected(self, sentinel) do |promise, done|
        handler1 = Minitest::Mock.new.expect(:call, nil, [sentinel])
        handler2 = Minitest::Mock.new.expect(:call, nil, [sentinel])
        handler3 = Minitest::Mock.new.expect(:call, nil, [sentinel])
        spy = Minitest::Mock.new

        promise.then(spy, handler1)
        promise.then(spy, ->(reason) { handler2.call(reason); throw(other) })
        promise.then(spy, handler3)

        promise.then nil, ->(reason) {
          reason.must_equal sentinel
          [handler1, handler2, handler3, spy].each(&:verify)
          done.call
        }
      end
    end

    describe "results in multiple branching chains with their own fulfillment values" do
      PromisesAplus.test_rejected(self, sentinel) do |promise, done|
        semi_done = CallbackAggregator.new(3, done)

        promise.then(nil, ->(reason) {
          sentinel
        }).then(->(value) {
          value.must_equal sentinel
          semi_done.call
        })

        promise.then(nil, ->(reason) {
          raise Exception.new(sentinel2)
        }).then(nil, ->(reason) {
          reason.to_s.must_equal sentinel2.to_s
          semi_done.call
        })

        promise.then(nil, ->(reason) {
          sentinel3
        }).then(->(value) {
          value.must_equal sentinel3
          semi_done.call
        })
      end
    end

    describe "`onRejected` handlers are called in the original order" do
      PromisesAplus.test_rejected(self, dummy) do |promise, done|
        handler1 = Minitest::Mock.new.expect(:call, 1, [dummy])
        handler2 = Minitest::Mock.new.expect(:call, 2, [dummy])
        handler3 = Minitest::Mock.new.expect(:call, 3, [dummy])
        sequence = Minitest::Mock.new.expect(:call, nil, [1]).expect(:call, nil, [2]).expect(:call, nil, [3])

        promise.then(nil, handler1).then(sequence)
        promise.then(nil, handler2).then(sequence)
        promise.then(nil, handler3).then(sequence)

        promise.then nil, ->(reason) {
          reason.must_equal dummy
          [handler1, handler2, handler3, sequence].each(&:verify)
          done.call
        }
      end

      describe "even when one handler is added inside another handler" do
        PromisesAplus.test_rejected(self, dummy) do |promise, done|
          handler1 = Minitest::Mock.new.expect(:call, 1, [dummy])
          handler2 = Minitest::Mock.new.expect(:call, 2, [dummy])
          handler3 = Minitest::Mock.new.expect(:call, 3, [dummy])
          sequence = Minitest::Mock.new.expect(:call, nil, [1]).expect(:call, nil, [2]).expect(:call, nil, [3])

          # TODO: The JavaScript spec adds handler3 inside this handler,
          # but since we don't have the delayed execution of handlers, we can't do that!
          promise.then nil, ->(reason) {
            sequence.call(handler1.call(reason))
            promise.then(nil, handler2).then(sequence)
          }
          promise.then(nil, handler3).then(sequence)

          promise.then nil, ->(reason) {
            reason.must_equal dummy
            [handler1, handler2, handler3, sequence].each(&:verify)
            done.call
          }
        end
      end
    end
  end
end