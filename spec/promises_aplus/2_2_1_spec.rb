# encoding: UTF-8
require_relative "../spec_helper"
require_relative "../promises_aplus"

dummy = { dummy: "dummy" }

describe "2.2.1: Both `onFulfilled` and `onRejected` are optional arguments." do
  include PromisesAplus

  describe "2.2.1.1: If `onFulfilled` is not a function, it must be ignored." do
    [nil, false, 5, Object.new].each do |non_function|
      describe "applied to a directly-rejected promise" do
        it "`onFulfilled` is `#{non_function.inspect}`" do
          rejected(dummy).then(non_function, ->(r) {
            done!
          })
        end
      end

      describe "applied to a promise rejected and then chained off of" do
        it "`onFulfilled` is #{non_function.inspect}" do
          rejected(dummy).then(->(v) { }, nil).then(non_function, ->(r) {
            done!
          })
        end
      end
    end
  end

  describe "2.2.1.2: If `onRejected` is not a function, it must be ignored." do
    [nil, false, 5, Object.new].each do |non_function|
      describe "applied to a directly-fulfilled promise" do
        it "`onRejected` is `#{non_function.inspect}`" do
          resolved(dummy).then(->(v) {
            done!
          }, non_function)
        end
      end

      describe "applied to a promise fulfilled and then chained off of" do
        it "`onRejected` is `#{non_function.inspect}`" do
          resolved(dummy).then(nil, ->(r) { }).then(->(v) {
            done!
          }, non_function)
        end
      end
    end
  end
end
