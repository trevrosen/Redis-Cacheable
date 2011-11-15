require "spec_helper"

module RedisCacheable
  Foobar = Class.new
  FooBar = Class.new
  RedisCacheable::FooClass = Class.new

  describe Util do
    describe ".underscore" do
      it "should make a pretty underscore replacement for ConstantCase" do
        Util.underscore("FooBar").should == "foo_bar"
      end

      it "should make a slash-based representation of a namespaced class" do
        Util.underscore("RedisCacheable::FooClass").should == "redis_cacheable/foo_class"
      end
    end
  end
end
