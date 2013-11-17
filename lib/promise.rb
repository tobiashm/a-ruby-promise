require "promise/version"

class Promise

  attr_reader :state, :value, :reason

  def initialize(&block)
    @state = :pending
    @value = nil
    @reason = nil
    @callbacks = []
    @errbacks = []
    instance_eval(&block) if block_given?
  end

  %w[pending fulfilled rejected].each do |state|
    define_method("#{state}?") { @state == state.to_sym }
  end

  def then(on_fulfilled = nil, on_rejected = nil)
    result = Promise.new

    call_and_fulfill = ->(value) {
      begin
        if function?(on_fulfilled)
          new_value = on_fulfilled.call(value)
          if Promise === new_value
            new_value.then(->(v) { result.fulfill(v) }, ->(r) { result.reject(r) })
          else
            result.fulfill(new_value)
          end
        else
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
        else
          result.reject(reason)
        end
      rescue Exception => e
        result.reject(e)
      end
    }

    case @state
    when :pending
      @callbacks << call_and_fulfill
      @errbacks << call_and_reject
    when :fulfilled
      call_and_fulfill.call(@value)
    when :rejected
      call_and_reject.call(@reason)
    end

    result
  end

protected

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

private

  def function?(obj)
    obj.respond_to? :call
  end
end
