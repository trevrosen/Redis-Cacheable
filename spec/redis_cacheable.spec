require "spec_helper"

describe RedisCacheable do
  before(:each) do
    $redis = stub("global redis connection")
  end

  let(:testclass1){
    Class.new do
      attr_accessor :id, :foo, :bar, :baz
      attr_accessor :some_string, :some_hash

      def initialize(id, some_string="", some_hash={})
        @id = id
        @some_string = some_string
        @some_hash = some_hash
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

  describe "when it is included into multiple classes" do
    before(:each) do
      testclass2.send(:include, RedisCacheable)
      subject.send(:include, RedisCacheable)
    end

    it "they should have different connections" do
      testclass2._rc_connection.should_not eql subject._rc_connection
    end

    it "they should have different namespaces" do
      testclass2.rc_config.namespace.should_not eql subject.rc_config.namespace
    end
  end


  describe "when it is included into a class" do
    before(:each) do
      subject.send(:include, RedisCacheable)
    end
    
    describe "the class" do
      let(:the_rc_config){subject.rc_config}

      [:namespace, :key_method, :cache_map].each do |method_name|
        it "should be able to get and set '#{method_name}'" do
          the_rc_config.send("#{method_name}=", "foothing")
          subject.rc_config.send("#{method_name}").should == "foothing"
        end
      end

      it "should create a Redis connection with Redis::Namespace" do
        p subject
        the_rc_config.namespace = "foospace"
        Redis::Namespace.should_receive(:new).with("foospace", :redis => $redis)
        subject._rc_connection
      end

    end
    
    describe "the instances" do
      let(:the_rc_config){subject.rc_config}
      let(:redis_connection) {Redis::Namespace.new("foospace", :redis => $redis)}

      before(:each) do
        @tc_instance = subject.new(5, "a string of stuff", {:this => "yeah", :that => "boo!"})
      end

      it "should use 'id' for the default key method" do
        @tc_instance.class.rc_config.key_method.should == :id
      end

      it "should use its cache key" do
        @tc_instance.rc_cache_key.should == "5"
      end

      it "should know when a copy is in Redis" do
        subject._rc_connection.stub(:keys).and_return ["5"]
        @tc_instance.exists_in_redis?.should be_true
      end
      
      it "should know when a copy is NOT in Redis" do
        subject._rc_connection.stub(:keys).and_return []
        @tc_instance.exists_in_redis?.should be_false
      end

      it "should return an empty string for #redis_string if there's nothing in Redis" do
        subject._rc_connection.stub(:keys).and_return []
        @tc_instance.redis_string.should == ""
      end

      describe "when reading from the cache" do
        before(:each) do
        end

        
      end

      describe "when writing to the cache" do
        it "should use a multi block to keep things transactional" do
          subject._rc_connection.should_receive(:multi)
          @tc_instance.rc_write!
        end



        describe "when the object contains things Marshal can't deal with " do
          before(:each) do
          end
          
          it "should raise an exception" do
            #expect{@tc_instance.rc_convert_and_write!}.to raise_error(RedisCacheable::NonConvertableClassError)
            pending
          end
        end
      end
    end
  end

  
end
