# Promise

[![Build Status](https://travis-ci.org/tobiashm/a-ruby-promise.png?branch=master)](https://travis-ci.org/tobiashm/a-ruby-promise)

This gem tries to be a Ruby version of the JavaScript Promises as defined by
http://promises-aplus.github.io/promises-spec/ and http://dom.spec.whatwg.org/#promises

## Installation

Add this line to your application's Gemfile:

    gem 'a-ruby-promise'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install a-ruby-promise

## Usage

Create a promise:
```ruby
Promise.new do
  begin
    # do some computation
    value = 42 # result of computation
    fulfill(value)
  rescue Exception => e
    reject(e)
  end
end
```

Create a new promise which will be rejected if it isn't fulfilled before a timeout period:
```ruby
def timeout_promise(promise, timeout_in_seconds)
  Promise.new do
    promise.then method(:fulfill)
    Thread.new do
      sleep timeout_in_seconds
      reject "Timeout reached"
    end
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
