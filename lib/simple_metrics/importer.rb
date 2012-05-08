module SimpleMetrics
  module Importer
    extend self
    
    def flush_raw(data)      
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
      SimpleMetrics.logger.info "#{Time.now} Flushing #{data_points.count} to MongoDB"

      ts   ||= Time.now.utc.to_i
      bucket = Bucket.first

      group_by_name(data_points) do |name, dps|
        dp = DataPoint.aggregate_values(dps)
        bucket.save(dp, ts)
        update_metric(dp, dps.size)
        aggregate_coarse_buckets(dp)  
      end
    end

    def aggregate_coarse_buckets(dp)
      coarse_buckets.each do |bucket|
        if existing_dp = bucket.find_data_point_at_ts(dp.ts, dp.name)
          bucket.update(existing_dp.combine(dp), existing_dp.ts)
        else
          bucket.save(dp, dp.ts)
        end
      end
    end

    private

    def group_by_name(dps, &block)
      dps.group_by { |dp| dp.name }.each_pair do |name,dps|
        block.call(name, dps)
      end
    end

    def update_metric(dp, total)
      if metric = MetricRepository.find_one_by_name(dp.name)
        metric.total += total
        MetricRepository.update(metric)
      else
        MetricRepository.save(Metric.new(:name => dp.name, :total => total))
      end
    end

    def coarse_buckets
      Bucket.all.sort_by! { |r| r.seconds }[1..-1]
    end
    
  end
end