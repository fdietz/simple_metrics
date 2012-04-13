# encoding: utf-8
module SimpleMetrics
  class Bucket

    class << self

      def all
        @@all ||= SimpleMetrics.config.buckets.map { |r| Bucket.new(r) }
      end

      def first
        all.first
      end

      def [](index)
        all[index]
      end

      def for_time(time)
        case time
        when 'minute'
          self[0]
        when 'hour'
          self[1]
        when 'day'
          self[2]
        when 'week'
          self[3]
        end
      end

    end

    attr_reader :name, :capped

    def initialize(attributes)
      @name    = attributes.fetch(:name)
      @seconds = attributes.fetch(:seconds)
      @capped  = attributes.fetch(:capped)
      @size    = attributes.fetch(:size)
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

    def find_all_in_ts_range_by_name(from, to, name)
      repository.find_all_in_ts_range_by_name(from, to, name)
    end

    def find_all_in_ts_range_by_wildcard(from, to, target)
      repository.find_all_in_ts_range_by_wildcard(from, to, target)
    end

    def save(dp, ts)
      dp.ts    = ts_bucket(ts)
      dp.sum   = dp.value
      dp.total = 1
      repository.save(dp)
    end

    def update(dp, ts)
      dp.ts = ts_bucket(ts)
      repository.update(dp, ts)
    end

    def capped?
      @capped == true
    end

    # TODO refactor, move to graph.rb ?
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
