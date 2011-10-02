require "spec_helper"

describe RedisCacheable do
  before(:each) do
    $redis = stub("global redis connection")
  end

  let(:testclass1){
    Class.new do
      attr_accessor :id, :foo, :bar, :baz

      def initialize(id)
        @id = id
      end
    end
  }

  let(:testclass2){
    Class.new do
      attr_accessor :id, :foo, :bar, :baz, :biff

      def initialize(id)
        @id = id
      end
    end
  }

  subject{testclass1}

  describe "when it is included into two classes" do
    before(:each) do
      testclass2.send(:include, RedisCacheable)
      subject.send(:include, RedisCacheable)
    
      testclass2.send(:rc_namespace, "class1")
      subject.send(:rc_namespace, "class2")
    end

    it "they should have different connections" do
      testclass2._rc_connection.should_not eql subject._rc_connection
    end

    it "they should have different namespaces" do
      testclass2._rc_namespace.should_not eql subject._rc_namespace
    end
  end


  describe "when it is included into a class" do
    before(:each) do
      subject.send(:include, RedisCacheable)
    end
    
    describe "the class" do
      it "should allow getting and setting the namespace" do
        subject.send(:rc_namespace, "foospace")
        subject._rc_namespace.should == "foospace"
      end

      it "should allow getting and setting the key method" do
        subject.send(:rc_key_method, "fooid")
        subject._rc_key_method.should == "fooid"
        
      end

      it "should allow getting and setting the cache map" do
        subject.send(:rc_cache_map, "foo_id")
        subject._rc_cache_map.should == "foo_id"
      end

      it "should create a Redis connection with Redis::Namespace" do
        subject.send(:rc_namespace, "foospace")
        Redis::Namespace.should_receive(:new).with("foospace", :redis => $redis)
        subject._rc_connection
      end

    end
    
    describe "the instances" do
      let(:redis_connection) {Redis::Namespace.new("foospace", :redis => $redis)}

      before(:each) do
        subject.send(:rc_key_method, :id)
        @tc_instance = subject.new(5)
      end

      it "should know whether a copy is in Redis" do
        subject._rc_connection.stub(:keys).and_return true
        @tc_instance.exists_in_redis?.should be_true
      end

      describe "when writing to the cache" do
        describe "without a cache map" do
          before(:each) do
            @tc_instance.class.stub(:_rc_cache_map).and_return nil
            $redis.stub(:set).and_return true
          end

          it "should use its cache key" do
            @tc_instance.rc_cache_key.should == "5"
          end

          it "should marshall via to_json if the class responds to that" do
            @tc_instance.stub(:respond_to?).with(:to_json).and_return true
            @tc_instance.should_receive(:to_json)
            @tc_instance.rc_write!
          end

          it "should marshall with to_hash.to_json if the class responds to to_hash but not to_json" do
            foo_hash = {:foo => "bar"}
            @tc_instance.stub(:respond_to?).with(:to_json).and_return false
            @tc_instance.stub(:respond_to?).with(:to_hash).and_return true
            @tc_instance.should_receive(:to_hash).and_return foo_hash
            foo_hash.should_receive(:to_json)
            @tc_instance.rc_write!
          end
          
        end
      end

    end
    
  end

  
end
