require "minitest/autorun"
require "a-ruby-promise"
require_relative "deferred"

Thread.abort_on_exception = true

def resolved(value)
  Promise.new { fulfill(value) }
end

def rejected(reason)
  Promise.new { reject(reason) }
end

def deferred
  Deferred.new
end

def short_sleep
  sleep 0.05
end

def longer_sleep
  sleep 0.1
end

def assert_unresolved(promise)
  promise.must_be :pending?
end

def assert_resolved(promise)
  promise.wont_be :pending?
end
