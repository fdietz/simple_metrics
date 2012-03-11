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
        stats1  =  DataPoint.create_counter(:name => "com.test.key1", :value => 5, :ts => ts)
        stats2  =  DataPoint.create_counter(:name => "com.test.key1", :value => 7, :ts => ts)
        stats3  =  DataPoint.create_counter(:name => "com.test.key1", :value => 9, :ts => (ts + 60) )

        results = ArrayAggregation.aggregate([stats1, stats2, stats3], "com.test.*")
        results.should have(2).data_points
        results.first.name.should == "com.test.*"
        results.last.name.should  == "com.test.*"
        results.first.value.should == 12
        results.last.value.should == 9
      end

      it "aggregates gauge data points" do
        stats1  =  DataPoint.create_gauge(:name => "com.test.key1", :value => 5, :ts => ts)
        stats2  =  DataPoint.create_gauge(:name => "com.test.key1", :value => 7, :ts => ts)
        stats3  =  DataPoint.create_gauge(:name => "com.test.key1", :value => 9, :ts => (ts + 60) )

        results = ArrayAggregation.aggregate([stats1, stats2, stats3], "com.test.*")
        results.should have(2).data_points
        results.first.name.should == "com.test.*"
        results.last.name.should  == "com.test.*"
        results.first.value.should == 6
        results.last.value.should == 9
      end
      
      it "raises NonMatchingTypesError if types are different" do
        stats1  =  DataPoint.create_counter(:name => "com.test.key1", :value => 5, :ts => ts)
        stats2  =  DataPoint.create_gauge(:name => "com.test.key1", :value => 5, :ts => ts)
        expect { ArrayAggregation.aggregate([stats1, stats2], "com.test.*") }.to raise_error(SimpleMetrics::DataPoint::NonMatchingTypesError)
      end
    end
  end
end