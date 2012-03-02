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
        Mongo.truncate_collections
        Mongo.ensure_collections_exist
        bucket.save(stats, ts)
      end

      let(:stats) do
        DataPoint.create_counter(:name => "key1", :value => 5)
      end

      it "saves given data in bucket" do
        results = bucket.find_all_by_name("key1")
        results.should have(1).item
        result = results.first
        result.name.should  == stats.name
        result.value.should == stats.value
        result.type.should  == stats.type
      end

      it "saves data in correct timestamp" do
        result = bucket.find_all_by_name("key1").first
        result.ts.should == ts/sec*sec
      end

    end # describe "#save" do

    describe "finder methods" do

      before do
        Mongo.truncate_collections
        Mongo.ensure_collections_exist
      end

      describe "#find_all_by_name" do
        it "returns all stats for given name" do
          stats_same1 =  DataPoint.create_counter(:name => "key1", :value => 5)
          stats_same2 =  DataPoint.create_counter(:name => "key1", :value => 3)
          stats_different = DataPoint.create_counter(:name => "key2", :value => 3)

          bucket.save(stats_same1, ts)
          bucket.save(stats_same2, ts)
          bucket.save(stats_different, ts)

          results = bucket.find_all_by_name("key1")
          results.should have(2).items
          results.first.name.should == stats_same1.name
        end
      end

      describe "#find_all_in_ts" do
        it "returns all stats in given timestamp" do
          stats1  =  DataPoint.create_counter(:name => "key1", :value => 5)
          stats2  =  DataPoint.create_counter(:name => "key2", :value => 3)

          bucket.save(stats1, ts)
          bucket.save(stats2, bucket.next_ts_bucket(ts))

          result1 = bucket.find_all_in_ts(ts).first
          result1.name.should == stats1.name
          result1.value.should == stats1.value

          result2 = bucket.find_all_in_ts(bucket.next_ts_bucket(ts)).first
          result2.name.should == stats2.name
          result2.value.should == stats2.value
        end
      end

      describe "#find_all_in_ts_by_name" do
        it "returns all stats for given name and timestamp" do
          stats1a  =  DataPoint.create_counter(:name => "key1", :value => 5)
          stats1b  =  DataPoint.create_counter(:name => "key1", :value => 7)
          stats2   =  DataPoint.create_counter(:name => "key2", :value => 7)
          stats1_different_ts   =  DataPoint.create_counter(:name => "key1", :value => 3)

          bucket.save(stats1a, ts)
          bucket.save(stats1b, ts)
          bucket.save(stats2, ts)
          bucket.save(stats1_different_ts, bucket.next_ts_bucket(ts))

          results = bucket.find_all_in_ts_by_name(ts, "key1")
          results.should have(2).items
          results.first.name.should == "key1"
          results.last.name.should == "key1"
        end
      end

    end # describe "finder methods"

    describe "#aggregate_all" do
      before do
        Mongo.truncate_collections
        Mongo.ensure_collections_exist
      end

      it "aggregates all stats" do
        stats1a  =  DataPoint.create_counter(:name => "key1", :value => 5)
        stats1b  =  DataPoint.create_counter(:name => "key1", :value => 7)
        stats2   =  DataPoint.create_counter(:name => "key2", :value => 3)

        bucket2 = Bucket[1]
        ts_at_insert = bucket2.previous_ts_bucket(ts)
        bucket.save(stats1a, ts_at_insert)
        bucket.save(stats1b, ts_at_insert)
        bucket.save(stats2, ts_at_insert)

        Bucket.aggregate_all(ts)

        results = bucket2.find_all_in_ts(ts_at_insert)
        results.should have(2).items

        key1_result = results.find {|stat| stat.name == "key1"}
        key1_result.value.should == 12
        key1_result.should be_counter

        key2_result = results.find {|stat| stat.name == "key2"}
        key2_result.value.should == 3
        key2_result.should be_counter
      end
    end # describe "#aggregate_all"

    describe "#flush_data_points" do
      before do
        stats1 = DataPoint.create_counter(:name => "key1", :value => 5)
        stats2 = DataPoint.create_counter(:name => "key1", :value => 7)
        stats3 = DataPoint.create_counter(:name => "key2", :value => 3)
        @stats = [stats1, stats2, stats3]
      end

      it "saves all stats in finest/first bucket" do
        Bucket.flush_data_points(@stats)

        results = bucket.find_all_in_ts(ts)
        results.should have(3).items
      end

      it "calls aggregate_all afterwards" do
        mock(Bucket).aggregate_all(ts)
        Bucket.flush_data_points(@stats)
      end
    end # describe "#flush_data_points"

  end
end
