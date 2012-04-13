module SimpleMetrics

  module Graph
    extend self

    def minutes; Bucket[0]; end
    def hours;   Bucket[1]; end
    def day;     Bucket[2]; end
    def week;    Bucket[3]; end

    def time_range(time)
      case time
      when 'minute'
        5 * one_minute
      when 'hour'
        one_hour
      when 'day'
        one_day
      when 'week'
        one_week
      else 
        raise "Unknown time param: #{time}"
      end
    end
    
    def query_all(bucket, from, to, *targets)
      results = []
      Array(targets).each do |target|
        results << { :name => target, :data => query(bucket, from, to, target).map { |data| { :x => data.ts, :y => data.value || 0 } } }
      end
      results
    end

    def query(bucket, from, to, target)
      if wild_card_query?(target)
        result = bucket.find_all_in_ts_range_by_wildcard(from, to, target)
        result = ArrayAggregation.aggregate(result, target)
        bucket.fill_gaps(from, to, result)
      elsif target.is_a?(String)
        result = bucket.find_all_in_ts_range_by_name(from, to, target)
        bucket.fill_gaps(from, to, result) 
      else
        raise ArgumentError, "Unknown target format: #{target.inspect}"
      end
    end

    private 

    def one_minute
      60
    end

    def one_hour
      one_minute * 60
    end

    def one_day
      one_hour * 24
    end

    def one_week
      one_day * 7
    end

    def wild_card_query?(target)
      target.is_a?(String) && target.include?('*')
    end
  
  end
end