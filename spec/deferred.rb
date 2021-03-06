class Deferred
  attr_reader :promise

  def initialize
    @promise = Promise.new
  end

  def fulfill(value)
    @promise.__send__(:fulfill, value)
  end
  alias_method :resolve, :fulfill

  def reject(reason)
    @promise.__send__(:reject, reason)
  end
end
