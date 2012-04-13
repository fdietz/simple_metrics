# encoding: utf-8
require "spec_helper"

module SimpleMetrics

  describe Graph do

  	let(:ts) do
      Time.now.utc.to_i
    end

    let(:bucket) do
      Bucket.first
    end

  	before do
  	  DataPointRepository.truncate_collections
  	  DataPointRepository.ensure_collections_exist
  	end

    describe "#query" do

      it "returns string request data points as is" do
      	dp1 = DataPoint::Counter.new(:name => "key1", :value => 5)

      	bucket.save(dp1, ts)

        current_ts = bucket.ts_bucket(ts)
      	from = current_ts
      	to   = current_ts
      	results = Graph.query(bucket, from, to, "key1")

      	results.should have(1).data_point
      end

      it "returns string request data points and fill graps" do
        dp1 = DataPoint::Counter.new(:name => "key1", :value => 5)

        bucket.save(dp1, ts)

        current_ts = bucket.ts_bucket(ts)
        from = current_ts
        to   = current_ts+10
        results = Graph.query(bucket, from, to, "key1")

        results.should have(2).data_point
        results.first.value.should == 5
        results.last.value.should be_nil
      end

      it "returns wildcard request data points with aggregate counter" do
      	dp1 = DataPoint::Counter.new(:name => "com.test.key1", :value => 5)
      	dp2 = DataPoint::Counter.new(:name => "com.test.key2", :value => 7)

      	bucket.save(dp1, ts)
      	bucket.save(dp2, ts)

      	current_ts = bucket.ts_bucket(ts)
        from = current_ts
        to   = current_ts
      	results = Graph.query(bucket, from, to, "com.test.*")
      	results.should have(1).data_point
      	result = results.first
      	result.name.should == "com.test.*"
      	result.value.should == 12
      	result.should be_counter
      end

    end # descibe

    describe "#query_all" do

      it "returns request data points as is" do
        dp1 = DataPoint::Counter.new(:name => "com.test.key1", :value => 5)
        dp2 = DataPoint::Counter.new(:name => "com.test.key2", :value => 7)
        dp3 = DataPoint::Counter.new(:name => "com.test.key2", :value => 3)
        bucket.save(dp1, ts)
        bucket.save(dp2, ts - 10)
        bucket.save(dp3, ts)

        current_ts = bucket.ts_bucket(ts)
        from = current_ts - 10
        to   = current_ts
        results = Graph.query_all(bucket, from, to, "com.test.key1", "com.test.key2")
        key1 = results.first
        key1[:name].should == "com.test.key1"
        key1[:data].should have(2).entry
        key1[:data].first[:y].should == 0
        key1[:data].last[:y].should == 5

        key2 = results.last
        key2[:name].should == "com.test.key2"
        key2[:data].should have(2).entry
        key2[:data].first[:y].should == 7
        key2[:data].last[:y].should == 3
      end

    end
  end
end
