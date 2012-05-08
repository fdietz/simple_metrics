# encoding: utf-8
require "spec_helper"

module SimpleMetrics

  describe Bucket do

    let(:bucket) do
      Bucket.first
    end

    let(:sec) do
      bucket.seconds
    end

    let(:ts) do
      Time.now.utc.to_i
    end

    describe "#ts_bucket" do
      it "calculates timestamp for current bucket" do
        bucket.ts_bucket(ts).should == ts/sec*sec
      end
    end

    describe "#next_ts_bucket" do
      it "calculates timestamp for next bucket" do
        bucket.next_ts_bucket(ts).should == ts/sec*sec+sec
      end
    end

    describe "#previous_ts_bucket" do
      it "calculates timestamp for previous bucket" do
        bucket.previous_ts_bucket(ts).should == ts/sec*sec-sec
      end
    end

    describe "#save" do
      before do
        DataPointRepository.truncate_collections
        DataPointRepository.ensure_collections_exist
        bucket.save(stats, ts)
      end

      let(:stats) do
        DataPoint::Counter.new(:name => "key1", :value => 5)
      end

      it "saves given data in bucket" do
        results = bucket.find_all_at_ts(ts)
        results.should have(1).item
        result = results.first
        result.name.should  == stats.name
        result.value.should == stats.value
        result.type.should  == stats.type
      end

      it "saves data in correct timestamp" do
        result = bucket.find_all_at_ts(ts).first
        result.ts.should == ts/sec*sec
      end

    end # describe "#save" do

    describe "finder methods" do

      before do
        DataPointRepository.truncate_collections
        DataPointRepository.ensure_collections_exist
      end

      describe "#find_all_at_ts" do
        it "returns all stats in given timestamp" do
          stats1  =  DataPoint::Counter.new(:name => "key1", :value => 5)
          stats2  =  DataPoint::Counter.new(:name => "key2", :value => 3)

          bucket.save(stats1, ts)
          bucket.save(stats2, bucket.next_ts_bucket(ts))

          result1 = bucket.find_all_at_ts(ts).first
          result1.name.should == stats1.name
          result1.value.should == stats1.value

          result2 = bucket.find_all_at_ts(bucket.next_ts_bucket(ts)).first
          result2.name.should == stats2.name
          result2.value.should == stats2.value
        end
      end

      describe "#find_all_in_ts_range_by_wildcard" do
        it "returns all stats for given name and timestamp" do
          stats1  =  DataPoint::Counter.new(:name => "com.test.key1", :value => 5)
          stats2  =  DataPoint::Counter.new(:name => "com.test.key2", :value => 7)
          stats_different =  DataPoint::Counter.new(:name => "com.test2.key1", :value => 3)

          from = bucket.ts_bucket(ts)
          to   = from
          bucket.save(stats1, ts)
          bucket.save(stats2, ts)
          bucket.save(stats_different, ts)

          results = bucket.find_all_in_ts_range_by_wildcard(from, to, "com.test.*")

          results.should have(2).items
          results.first.name.should == "com.test.key1"
          results.last.name.should == "com.test.key2"
        end
      end

      describe "#fill_gaps" do
        it "returns stats and fills missing gaps with null entries" do
          stats  =  DataPoint::Counter.new(:name => "com.test.key1", :value => 5)

          from = ts - 10
          to   = ts + 10
          bucket.save(stats, ts)
          ts_bucket = bucket.ts_bucket(ts)

          results = bucket.fill_gaps(from, to, [stats])

          results.should have(3).items
          results[0].name.should == "com.test.key1"
          results[1].name.should == "com.test.key1"
          results[2].name.should == "com.test.key1"

          results[0].value.should be_nil
          results[1].value.should == 5
          results[2].value.should be_nil

          results[0].ts.should == ts_bucket - 10
          results[1].ts.should == ts_bucket
          results[2].ts.should == ts_bucket + 10
        end
      end
    end # describe "finder methods"

  end
end
