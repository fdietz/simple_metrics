# encoding: utf-8
require "spec_helper"

module SimpleMetrics

  describe ArrayAggregation do

    before do
      DataPointRepository.truncate_collections
      DataPointRepository.ensure_collections_exist
    end

    let(:ts) do
      Time.now.utc.to_i
    end

    describe "#aggregate" do
      it "aggregates counter data points" do
        stats1  =  DataPoint.create_counter(:name => "key1", :value => 5)
        stats2  =  DataPoint.create_counter(:name => "key1", :value => 7)
        result = ValueAggregation.aggregate([stats1, stats2])
        result.value.should == 12
        result.name.should == "key1"
        result.should be_counter
      end

      it "aggregates counter data points with custom name" do
        stats1  =  DataPoint.create_counter(:name => "key1", :value => 5)
        stats2  =  DataPoint.create_counter(:name => "key1", :value => 7)
        result = ValueAggregation.aggregate([stats1, stats2], "new_name")
        result.value.should == 12
        result.name.should == "new_name"
        result.should be_counter
      end

      it "aggregates gauge data points" do
        stats1  =  DataPoint.create_gauge(:name => "key1", :value => 5)
        stats2  =  DataPoint.create_gauge(:name => "key1", :value => 7)
        result = ValueAggregation.aggregate([stats1, stats2])
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