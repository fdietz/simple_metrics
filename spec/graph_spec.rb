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
  	  Mongo.truncate_collections
  	  Mongo.ensure_collections_exist
  	end

    describe "#query" do

      it "returns string request data points as is" do
      	dp1 = DataPoint.create_counter(:name => "key1", :value => 5)

      	bucket.save(dp1, ts)

        current_ts = bucket.ts_bucket(ts)
      	from = current_ts
      	to   = current_ts
      	results = Graph.query(bucket, from, to, "key1")

      	results.should have(1).data_point
      end

      it "returns string request data points and fill graps" do
        dp1 = DataPoint.create_counter(:name => "key1", :value => 5)

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
      	dp1 = DataPoint.create_counter(:name => "com.test.key1", :value => 5)
      	dp2 = DataPoint.create_counter(:name => "com.test.key2", :value => 7)

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

    end
  end
end
