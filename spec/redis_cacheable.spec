require "spec_helper"

describe RedisCacheable do
  before(:each) do
    $redis = stub("global redis connection")
  end

  let(:testclass1){
    Class.new do
      attr_accessor :id, :foo, :bar, :baz

      def intialize(id)
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


  describe "when it is included into a class" do
    before(:each) do
      subject.send(:include, RedisCacheable)
    end
    
    describe "the class" do
      it "should allow setting the namespace" do
        subject.send(:rc_namespace, "foospace")
        subject._rc_config[:namespace].should == "foospace"
      end

      it "should allow setting the key method" do
        subject.send(:rc_key_method, "fooid")
        subject._rc_config[:key_method].should == "fooid"
        
      end

      it "should allow setting the cache map" do
        subject.send(:rc_cache_map, "foo_id")
        subject._rc_config[:cache_map].should == "foo_id"
      end

      it "should create a Redis connection with Redis::Namespace" do
        subject.send(:rc_namespace, "foospace")
        Redis::Namespace.should_receive(:new).with("foospace", :redis => $redis)
        subject._rc_connection
      end

    end
    
    describe "the instances" do
      let(:tc_instance) {subject.new(5)}
      let(:redis_connection) {Redis::Namespace.new("foospace", :redis => $redis)}

      describe "when writing to the cache" do
        describe "without a cache map" do
          before(:each) do
            tc_instance.class.stub(:_rc_cache_map).and_return nil
            tc_instance.class.send(:rc_key_method, :id)
            $redis.stub(:set).and_return true
          end

          it "should marshall via to_json if the class responds to that" do
            tc_instance.should_receive(:respond_to?).with(:to_json).and_return true
            puts "the cache key: #{ tc_instance.rc_cache_key}"
            tc_instance.should_receive(:to_json)
            tc_instance.rc_write
          end

          it "should marshall with to_hash.to_json if the class responds to to_hash but not to_json" do
          end
          
        end
      end

    end
    
  end

  
end
