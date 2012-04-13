# encoding: utf-8
require "spec_helper"

module SimpleMetrics

  describe DataPointRepository do

    before do
      DataPointRepository.truncate_collections
      DataPointRepository.ensure_collections_exist
    end

    let(:ts) do
      Time.now.utc.to_i
    end

    let(:repository) do
      DataPointRepository.for_retention('stats_per_10s')
    end

    describe "#save" do
      it "saves data point correctly" do
        dp = DataPoint::Counter.new(:name => "key", :ts => ts)
        repository.save(dp)

        results = repository.find_all_at_ts(ts)
        results.should have(1).data_point
      end
    end    

    describe "#find_all_at_ts" do
      it "returns all data points at given time stamp" do
        dp1 = DataPoint::Counter.new(:name => "key1", :ts => ts)
        dp2 = DataPoint::Counter.new(:name => "key1", :ts => ts + 10)
        repository.save(dp1)
        repository.save(dp2)

        results = repository.find_all_at_ts(ts)
        results.should have(1).data_point
        results.first.name.should == "key1"
      end
    end    

    describe "#find_all_in_ts_range_by_name" do
      it "returns all data points in given time stamp range by name" do
        dp1 = DataPoint::Counter.new(:name => "key1", :ts => ts)
        dp2 = DataPoint::Counter.new(:name => "key2", :ts => ts + 10)
        dp3 = DataPoint::Counter.new(:name => "key3", :ts => ts + 20)
        repository.save(dp1)
        repository.save(dp2)
        repository.save(dp3)

        results = repository.find_all_in_ts_range_by_name(ts, ts+10, "key1")
        results.should have(1).data_point
        results.first.name.should == "key1"
      end
    end

    describe "#find_all_in_ts_range_by_wildcard" do
      it "returns all data points in given time stamp range by wildcard" do
        dp1 = DataPoint::Counter.new(:name => "test.key1", :ts => ts)
        dp2 = DataPoint::Counter.new(:name => "test.key2", :ts => ts + 10)
        dp3 = DataPoint::Counter.new(:name => "test.key3", :ts => ts + 20)
        repository.save(dp1)
        repository.save(dp2)
        repository.save(dp3)

        results = repository.find_all_in_ts_range_by_wildcard(ts, ts+10, "test.*")
        results.should have(2).data_point2
        results.first.name.should == "test.key1"
        results.last.name.should == "test.key2"
      end
    end

  end

end