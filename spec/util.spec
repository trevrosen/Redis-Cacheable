require "spec_helper"

module RedisCacheable
  describe Util do
    describe "#underscore" do
      it "should make a pretty underscore replacement a la ActiveSupport" do
        Util.underscore("FooBar").should == "foo_bar"
      end
    end
  end
end
