require "spec_helper"

describe RedisCacheable do
  before(:each) do
    $redis = stub("global redis connection")
  end

  let(:testclass1){
    Class.new do
      attr_accessor :id, :foo, :bar, :baz
      attr_accessor :some_string, :some_hash

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

      [:namespace, :key_method].each do |method_name|
        it "should be able to get and set '#{method_name}'" do
          the_rc_config.send("#{method_name}=", "foothing")
          subject.rc_config.send("#{method_name}").should == "foothing"
        end
      end

      it "should create a Redis connection with Redis::Namespace" do
        the_rc_config.namespace = "foospace"
        Redis::Namespace.should_receive(:new).with("foospace", :redis => $redis)
        subject._rc_connection
      end

    end
    
    describe "the instances" do
      let(:the_rc_config){subject.rc_config}
      let(:redis_connection) {Redis::Namespace.new("foospace", :redis => $redis)}

      before(:each) do
        @tc_instance = subject.new(5)
      end

      it "should use 'id' for the default key method" do
        @tc_instance.class.rc_config.key_method.should == :id
      end

      describe "when writing to the cache" do
        
      end
    end
  end


end
