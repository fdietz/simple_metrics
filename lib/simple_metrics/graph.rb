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

    private

    def query(bucket, from, to, target)
      if target.is_a?(RegExp) 
        bucket.find_all_by_regexp(from, to, target)
      elsif target.is_a?(String) && target.include?('*')
        bucket.find_all_by_wildcard(from, to, target)
      elsif target.is_a?(String)
        bucket.find_all_by_name(from, to, target)
      else
        raise ArgumentError, "Unknown target: #{target.inspect}"
      end
    end

    def values_only(data_point_array)
      data_point_array.map { |data| data.value }
    end
  end
end