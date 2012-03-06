# encoding: utf-8
require "spec_helper"

module SimpleMetrics

  describe Bucket do

    describe "#parse" do

      it "parses increment counter" do
        stats = DataPoint.parse("com.example.test1:1|c")
        stats.name.should == "com.example.test1"
        stats.value.should == 1
        stats.should be_counter
      end

      it "parses decrement counter" do
        stats = DataPoint.parse("com.example.test1:-1|c")
        stats.name.should == "com.example.test1"
        stats.value.should == -1
        stats.should be_counter
      end

      it "parses counter with sample rate" do
        stats = DataPoint.parse("com.example.test2:5|c|@0.1")
        stats.name.should == "com.example.test2"
        stats.value.should == 50
        stats.should be_counter
      end

      it "parses increment gauge" do
        stats = DataPoint.parse("com.example.test3:5|g")
        stats.name.should == "com.example.test3"
        stats.value.should == 5
        stats.should be_gauge
      end

      it "parses increment gauge with sample rate" do
        stats = DataPoint.parse("com.example.test3:5|g|@0.1")
        stats.name.should == "com.example.test3"
        stats.value.should == 50
        stats.should be_gauge
      end

      it "parses increment timing" do
        stats = DataPoint.parse("com.example.test4:44|ms")
        stats.name.should == "com.example.test4"
        stats.value.should == 44
        stats.should be_timing
      end

      it "parses increment timing with sample rate" do
      end
    end


    describe "aggregate" do
      it "aggregates counter data points" do
        stats1  =  DataPoint.create_counter(:name => "key1", :value => 5)
        stats2  =  DataPoint.create_counter(:name => "key1", :value => 7)
        result = DataPoint.aggregate([stats1, stats2])
        result.value.should == 12
        result.name.should == "key1"
        result.should be_counter
      end

      it "aggregates gauge data points" do
        stats1  =  DataPoint.create_gauge(:name => "key1", :value => 5)
        stats2  =  DataPoint.create_gauge(:name => "key1", :value => 7)
        result = DataPoint.aggregate([stats1, stats2])
        result.value.should == 6
        result.name.should == "key1"
        result.should be_gauge
      end

      it "aggregates timing data points" do
      end
      
      it "aggregates event data points" do
      end
    end
  end

end