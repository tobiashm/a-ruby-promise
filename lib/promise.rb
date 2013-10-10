require "promise/version"

class Promise

  attr_reader :state, :value, :reason

  def initialize(&block)
    @state = :pending
    @value = nil
    @reason = nil
    @callbacks = []
    @errbacks = []
    yield method(:fulfill), method(:reject) if block_given?
  end

  def fulfill(value)
    return unless @state == :pending
    @state = :fulfilled
    @value = value
    while callback = @callbacks.shift
      callback.call(value) rescue nil
    end
  end

  def reject(reason)
    return unless @state == :pending
    @state = :rejected
    @reason = reason
    while errback = @errbacks.shift
      errback.call(reason) rescue nil
    end
  end

  def then(on_fulfilled = nil, on_rejected = nil)
    result = Promise.new

    call_and_fulfill = ->(value) {
      begin
        # From 3.2.1, don't call non-functions values
        if function?(on_fulfilled)
          new_value = on_fulfilled.call(value)
          if Promise === new_value
            new_value.then(->(v) { result.fulfill(v) }, ->(r) { result.reject(r) })
          else
            result.fulfill(new_value)
          end
        elsif !on_fulfilled.nil?
          # From 3.2.6.4
          result.fulfill(value)
        end
      rescue Exception => e
        result.reject(e)
      end
    }

    call_and_reject = ->(reason) {
      begin
        if function?(on_rejected)
          new_value = on_rejected.call(reason)
          if Promise === new_value
            new_value.then(->(v) { result.fulfill(v) }, ->(r) { result.reject(r) })
          else
            result.fulfill(new_value)
          end
        elsif !on_rejected.nil?
          # From 3.2.6.5
          result.reject(reason)
        end
      rescue Exception => e
        result.reject(e)
      end
    }

    case @state
    when :pending
      @callbacks << call_and_fulfill if on_fulfilled
      @errbacks << call_and_reject if on_rejected
    when :fulfilled
      call_and_fulfill.call(@value)
    when :rejected
      call_and_reject.call(@reason)
    end

    result
  end

private

  def function?(obj)
    obj.respond_to? :call
  end
end