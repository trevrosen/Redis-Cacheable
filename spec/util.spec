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

    describe ".class_name_from_key_string" do

      it "should create class name from singular string" do
        #Util.class_name_from_key_string "foobar".should == Foobar
        pending
      end

      it "should create ConstantCase class name from underscored string" do
        #Util.class_name_from_key_string "foo_bar".should == Foobar
        pending
      end

      it "should create namespaced class name from string with a forward slash" do
        #Util.class_name_from_key_string "some_namespace/foo_class".should == SomeNamespace::FooClass
        pending
      end
    end
  end
end
