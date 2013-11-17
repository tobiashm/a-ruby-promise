module PromisesAplus
  def setup
    @done = false
  end

  def teardown
    time_limit = Time.now + 2
    loop do
      return if @done == true
      raise Minitest::Assertion.new("`done` was never called") if Time.now >= time_limit
      sleep 0.05
    end
  end

  def done!
    @done = true
  end

  def self.test_fulfilled(base, value, &test)
    base.it "already-fulfilled" do
      test.call(resolved(value), method(:done!))
    end

    base.it "immediately-fulfilled" do
      d = deferred()
      test.call(d.promise, method(:done!))
      d.resolve(value)
    end

    base.it "eventually-fulfilled" do
      d = deferred()
      test.call(d.promise, method(:done!))
      short_sleep
      d.resolve(value)
    end
  end

  def self.test_rejected(base, reason, &test)
    base.it "already-rejected" do
      test.call(rejected(reason), method(:done!))
    end

    base.it "immediately-rejected" do
      d = deferred
      test.call(d.promise, method(:done!))
      d.reject(reason)
    end

    base.it "eventually-rejected" do
      d = deferred
      test.call(d.promise, method(:done!))
      short_sleep
      d.reject(reason)
    end
  end
end