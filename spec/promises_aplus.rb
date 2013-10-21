module PromisesAplus
  def setup
    @done = false
  end

  def teardown
    eventually { @done.must_equal true }
  end

  def done!
    @done = true
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
end