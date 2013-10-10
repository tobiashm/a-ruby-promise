require "minitest/autorun"
require "a-ruby-promise"

def resolved(value)
  Promise.new { |fulfill, _| fulfill.call(value) }
end

def rejected(reason)
  Promise.new { |_, reject| reject.call(reason) }
end

def test_fulfilled(value, test)
  describe "already-fulfilled" do
    test.call resolved(value)
  end

  describe "immediately-fulfilled" do
    p = Promise.new
    test.call p
    p.fulfill(value)
  end

  describe "eventually-fulfilled" do
    p = Promise.new
    test.call p
    Thread.new do
      sleep(50)
      p.fulfill(value)
    end
  end
end

def test_rejected(reason, test)
  describe "already-rejected" do
    test.call rejected(reason)
  end

  describe "immediately-rejected" do
    p = Promise.new
    test.call p
    p.reject(reason)
  end

  describe "eventually-rejected" do
    p = Promise.new
    test.call p
    Thread.new do
      sleep(50)
      p.reject(reason)
    end
  end
end
