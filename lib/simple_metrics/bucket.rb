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

      def flush_raw_data(data)      
        data_points = []
        data.each do |str|
          begin
            data_points << DataPoint.parse(str)
          rescue DataPoint::ParserError => e
            SimpleMetrics.logger.debug "Invalid Data skipped: #{str}, #{e}"
          end
        end
        flush_data_points(data_points, Time.now.utc.to_i)
      end

      def flush_data_points(data_points, ts = nil)
        return if data_points.empty?
        SimpleMetrics.logger.info "#{Time.now} Flushing #{data_points.count} counters to MongoDB"

        ts   ||= Time.now.utc.to_i
        bucket = Bucket.first

        data_points.group_by { |dp| dp.name }.each_pair do |name,dps|
          dp = ValueAggregation.aggregate(dps)
          bucket.save(dp, ts)
          update_metric(dp)
          aggregate(dp)  
        end
      end

      def aggregate(dp)
        coarse_buckets.each do |bucket|
          existing_dp = bucket.find_data_point_at_ts(dp.ts, dp.name)
          if existing_dp
            UpdateAggregation.aggregate(existing_dp, dp)
            bucket.update(existing_dp, existing_dp.ts)
          else
            dp.sum   = dp.value
            dp.total = 1
            bucket.save(dp, dp.ts)
          end
        end
      end

      private

      def update_metric(dp)
        metric = MetricRepository.find_one_by_name(dp.name)
        if metric
          MetricRepository.update(Metric.new(:name => dp.name, :total => metric.total + 1))
        else
          MetricRepository.save(Metric.new(:name => dp.name, :total => 1))
        end
      end

      def coarse_buckets
        Bucket.all.sort_by! { |r| r.seconds }[1..-1]
      end

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
      (ts / seconds) * seconds
    end

    def next_ts_bucket(ts)
      ts_bucket(ts) + seconds
    end

    def previous_ts_bucket(ts)
      ts_bucket(ts) - seconds
    end

    # TODO: only used in tests, do we need it?
    def find_all_at_ts(ts)
      repository.find_all_at_ts(ts_bucket(ts))
    end

    def find_data_point_at_ts(ts, name)
      repository.find_data_point_at_ts(ts_bucket(ts), name)
    end

    # TODO: only used in tests, do we need it?
    def find_all_in_ts_range(from, to)
      repository.find_all_in_ts_range(from, to)
    end

    def find_all_in_ts_range_by_name(from, to, name)
      repository.find_all_in_ts_range_by_name(from, to, name)
    end

    def find_all_in_ts_range_by_wildcard(from, to, target)
      repository.find_all_in_ts_range_by_wildcard(from, to, target)
    end

    # TODO: only used in tests, do we need it?
    def data_points_exist_at_ts?(ts, name)
      repository.count_for_name_at(ts, name) > 0
    end

    # TODO: only used in tests, do we need it?
    def stats_exist_in_previous_ts?(ts)
      repository.count_at(ts) > 0
    end

    def find_all_distinct_names
      repository.find_all_distinct_names
    end

    def save(dp, ts)
      dp.ts = ts_bucket(ts)
      repository.save(dp)
      SimpleMetrics.logger.debug "SERVER: MongoDB - insert in #{name}: #{dp.inspect}"
    end

    def update(dp, ts)
      dp.ts = ts_bucket(ts)
      repository.update(dp, ts)
      SimpleMetrics.logger.debug "SERVER: MongoDB - update in #{name}: #{dp.inspect}"
    end

    def capped?
      @capped == true
    end

    # TODO refactor, move to graph.rb
    def fill_gaps(from, to, query_result)
      return query_result if query_result.nil? || query_result.size == 0
      
      tmp_hash = DataPoint.ts_hash(query_result)
      dp_template = query_result.first

      result = []
      each_ts(from, to) do |current_bucket_ts|
        result <<  
          if tmp_hash.key?(current_bucket_ts)
            tmp_hash[current_bucket_ts]
          else
            dp       = dp_template.dup
            dp.value = nil
            dp.ts    = current_bucket_ts
            dp
          end
      end
      result
    end

    private

    def repository
      DataPointRepository.for_retention(name)
    end

    def each_ts(from, to)
      current_bucket_ts = ts_bucket(from)
      while (current_bucket_ts <= ts_bucket(to))
        yield(current_bucket_ts)
        current_bucket_ts = current_bucket_ts + seconds
      end
    end

  end
end
