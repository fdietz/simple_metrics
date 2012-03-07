# encoding: utf-8
module SimpleMetrics
  class Bucket

    class << self

      def all
        @@all ||= SimpleMetrics.buckets_config.map { |r| Bucket.new(r) }
      end

      def first
        all.first
      end
      alias :finest :first

      def [](index)
        all[index]
      end

      def coarse_buckets
        Bucket.all.sort_by! { |r| r.seconds }[1..-1]
      end

      def flush_data_points(data_points)
        return if data_points.empty?
        SimpleMetrics.logger.info "#{Time.now} Flushing #{data_points.count} counters to MongoDB"

        ts = Time.now.utc.to_i
        bucket = Bucket.first
        data_points.each { |data| bucket.save(data, ts) }
        
        self.aggregate_all(ts)
      end

      def aggregate_all(ts)
        ts_bucket = self.first.ts_bucket(ts)

        coarse_buckets.each do |bucket|
          current_ts = bucket.ts_bucket(ts_bucket)
          previous_ts = bucket.previous_ts_bucket(ts_bucket)
          SimpleMetrics.logger.debug "Aggregating #{bucket.name} #{previous_ts}....#{current_ts} (#{humanized_timestamp(previous_ts)}..#{humanized_timestamp(current_ts)})"

          unless bucket.stats_exist_in_previous_ts?(previous_ts)
            data_points = self.first.find_all_in_ts_range(previous_ts, current_ts)
            data_points.group_by { |data| data.name }.each_pair do |name,dps|
              data = DataPoint.aggregate(dps)
              bucket.save(data, previous_ts)
            end
          end
        end
      end

      private

      def humanized_timestamp(ts)
        Time.at(ts).utc
      end
    end

    attr_reader :name, :capped

    def initialize(attributes)
      @name    = attributes[:name]
      @seconds = attributes[:seconds]
      @capped  = attributes[:capped]
      @size    = attributes[:size]
    end

    def seconds
      @seconds.to_i
    end

    def size
      @size.to_i
    end

    def ts_bucket(ts)
      ts / seconds * seconds
    end

    def next_ts_bucket(ts)
      ts_bucket(ts) + seconds
    end

    def previous_ts_bucket(ts)
      ts_bucket(ts) - seconds
    end

    def find(id)
      mongo_result = mongo_coll.find_one({ :_id => id })
      DataPoint.create_from_db(mongo_result)
    end

    def find_all_by_name(name)
      mongo_result = mongo_coll.find({ :name => name })
      mongo_result.inject([]) { |result, a| result << DataPoint.create_from_db(a) }
    end

    def find_all_in_ts(ts)
      mongo_result = mongo_coll.find({ :ts => ts_bucket(ts) })
      mongo_result.inject([]) { |result, a| result << DataPoint.create_from_db(a) }
    end

    def find_all_in_ts_by_name(ts, name)
      mongo_result = mongo_coll.find({ :ts => ts_bucket(ts), :name => name })
      mongo_result.inject([]) { |result, a| result << DataPoint.create_from_db(a) }
    end

    def find_all_in_ts_range(from, to)
      mongo_result = mongo_coll.find({ :ts => { "$gte" => from, "$lt" => to }}).to_a
      mongo_result.inject([]) { |result, a| result << DataPoint.create_from_db(a) }
    end

    def find_all_in_ts_range_by_name(from, to, name)
      mongo_result = mongo_coll.find({ :name => name, :ts => { "$gte" => from, "$lt" => to }}).to_a
      mongo_result.inject([]) { |result, a| result << DataPoint.create_from_db(a) }
    end

    def find_all_in_ts_range_by_wildcard(from, to, target)
      target = target.gsub('.', '\.')
      target = target.gsub('*', '.*')
      mongo_result = mongo_coll.find({ :name => /#{target}/, :ts => { "$gte" => from, "$lt" => to } })
      mongo_result.inject([]) { |result, a| result << DataPoint.create_from_db(a) }
    end

    def find_all_in_ts_range_by_regexp(from, to, target)
      mongo_result = mongo_coll.find({ :name => /#{target}/, :ts => { "$gte" => from, "$lt" => to } })
      mongo_result.inject([]) { |result, a| result << DataPoint.create_from_db(a) }
    end

    def stats_exist_in_previous_ts?(ts)
      mongo_coll.find({ :ts => ts }).count > 0
    end

    def find_all_distinct_names
      mongo_coll.distinct(:name).to_a
    end

    def save(stats, ts)
      stats.ts = ts_bucket(ts)
      result = mongo_coll.insert(stats.attributes)
      SimpleMetrics.logger.debug "SERVER: MongoDB - insert in #{name}: #{stats.inspect}, result: #{result}"
    end

    def mongo_coll
      Mongo.collection(name)
    end

    def capped?
      @capped == true
    end

  end
end
