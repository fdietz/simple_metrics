module SimpleMetrics

  # 
  # url format examples:
  # * target=com.post.clicks (1 line in graph)
  # * target=com.post.clicks.text&target=com.post.clicks.logo (2 lines in graph)
  # * target=com.post.clicks.* (1 aggregated line in graph)
  #
  module Graph
    extend self

    def minutes
      Bucket[0]
    end

    def hours
      Bucket[1]
    end

    def day
      Bucket[2]
    end

    def week
      Bucket[3]
    end

    def query_all(bucket, from, to, *targets)
      result = {}
      Array(targets).each do |target|
        result[target.inspect] = values_only(query(bucket, from, to, target))
      end
      result
    end

    def query(bucket, from, to, target)
      if target.is_a?(Regexp) 
        result = bucket.find_all_in_ts_range_by_regexp(from, to, target)
        result = DataPoint.aggregate_array(result, target.inspect)
        bucket.fill_gaps(from, to, result)
      elsif target.is_a?(String) && target.include?('*')
        result = bucket.find_all_in_ts_range_by_wildcard(from, to, target)
        result = DataPoint.aggregate_array(result, target)
        bucket.fill_gaps(from, to, result)
      elsif target.is_a?(String)
        result = bucket.find_all_in_ts_range_by_name(from, to, target)
        bucket.fill_gaps(from, to, result)
      else
        raise ArgumentError, "Unknown target: #{target.inspect}"
      end
    end

    def values_only(data_point_array)
      data_point_array.map { |data| { :ts => data.ts, :value => data.value } }
    end

  end
end