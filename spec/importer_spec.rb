# encoding: utf-8
require "spec_helper"

module SimpleMetrics

  describe Importer do

    let(:bucket) do
      Bucket.first
    end

    let(:ts) do
      Time.now.utc.to_i
    end

    describe "#aggregate_coarse_buckets" do
      before do
        DataPointRepository.truncate_collections
        DataPointRepository.ensure_collections_exist
      end

      it "aggregates all counter data points" do
        stats1a  =  DataPoint::Counter.new(:name => "key1", :value => 5)
        stats1b  =  DataPoint::Counter.new(:name => "key1", :value => 7)
        stats2   =  DataPoint::Counter.new(:name => "key2", :value => 3)

        bucket2 = Bucket[1]
        ts_at_insert = bucket2.previous_ts_bucket(ts)
        bucket.save(stats1a, ts_at_insert)
        Importer.aggregate_coarse_buckets(stats1a)
        bucket.save(stats1b, ts_at_insert)
        Importer.aggregate_coarse_buckets(stats1b)
        bucket.save(stats2, ts_at_insert)
        Importer.aggregate_coarse_buckets(stats2)

        results = bucket2.find_all_at_ts(ts_at_insert)
        results.should have(2).items

        key1_result = results.find {|stat| stat.name == "key1"}
        key1_result.value.should == 12
        key1_result.should be_counter

        key2_result = results.find {|stat| stat.name == "key2"}
        key2_result.value.should == 3
        key2_result.should be_counter
      end

      it "aggregates all gauge data points" do
        stats1a  =  DataPoint::Gauge.new(:name => "key1", :value => 5)
        stats1b  =  DataPoint::Gauge.new(:name => "key1", :value => 7)
        stats2   =  DataPoint::Gauge.new(:name => "key2", :value => 3)

        bucket2 = Bucket[1]
        ts_at_insert = bucket2.previous_ts_bucket(ts)
        bucket.save(stats1a, ts_at_insert)
        Importer.aggregate_coarse_buckets(stats1a)
        bucket.save(stats1b, ts_at_insert)
        Importer.aggregate_coarse_buckets(stats1b)
        bucket.save(stats2, ts_at_insert)
        Importer.aggregate_coarse_buckets(stats2)

        results = bucket2.find_all_at_ts(ts_at_insert)
        results.should have(2).items

        key1_result = results.find {|stat| stat.name == "key1"}
        key1_result.value.should == 6
        key1_result.should be_gauge

        key2_result = results.find {|stat| stat.name == "key2"}
        key2_result.value.should == 3
        key2_result.should be_gauge
      end

    end # describe "#aggregate_all"

    describe "#flush_data_points" do
      before do
        DataPointRepository.truncate_collections
        DataPointRepository.ensure_collections_exist
        MetricRepository.truncate_collections

        stats1 = DataPoint::Counter.new(:name => "key1", :value => 5)
        stats2 = DataPoint::Counter.new(:name => "key1", :value => 7)
        stats3 = DataPoint::Counter.new(:name => "key2", :value => 3)
        @stats = [stats1, stats2, stats3]
      end

      it "saves all stats in finest/first bucket" do
        Importer.flush_data_points(@stats)

        results = bucket.find_all_at_ts(ts)
        results.should have(2).items
      end

      it "saves all stats and aggregate if duplicates found" do
        Importer.flush_data_points(@stats)

        results = bucket.find_all_at_ts(ts)
        results.should have(2).items
        results.first.name.should == "key1"
        results.last.name.should == "key2"
        results.first.value == 12
        results.last.value == 3
      end

      it "raises error if name matches but type does not" do
        stats4 = DataPoint::Gauge.new(:name => "key1", :value => 3)
        input = @stats + [stats4]
        expect { Importer.flush_data_points(input) }.to raise_error(SimpleMetrics::DataPoint::NonMatchingTypesError)
      end

      it "increments metrics counter" do
        Importer.flush_data_points(@stats)
        key1 = MetricRepository.find_one_by_name("key1")
        key1.name.should == "key1"
        key1.total.should == 2
        key2 = MetricRepository.find_one_by_name("key2")
        key2.name.should == "key2"
        key2.total.should == 1
      end

    end # describe "#flush_data_points"

  end

end