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

def assert_unresolved(*promises)
  promises.each { |promise| promise.must_be :pending? }
end

def assert_resolved(*promises)
  promises.each { |promise| promise.wont_be :pending? }
end

def eventually(&block)
  time_limit = Time.now + 2
  loop do
    begin
      yield
    rescue Minitest::Assertion => error
    end
    return if error.nil?
    raise error if Time.now >= time_limit
    sleep 0.05
  end
end
