module SimpleMetrics
  module ArrayAggregation
    extend self

    class Base
      def aggregate(dps, name = nil)
        raise "subclass must implement me!"
      end

      private

      def ts_hash_aggregated(data_points, &block)
        tmp = {}
        data_points.each do |dp|
          if tmp.key?(dp.ts)
            tmp[dp.ts] = block.call(tmp[dp.ts], dp.value)
          else
            tmp[dp.ts] = dp.value
          end
        end
        tmp
      end
    end

    class Counter < Base
      def aggregate(dps, name = nil)
        tmp_hash = ts_hash_aggregated(dps) do |value1, value2|
          value1 + value2
        end

        result = []
        tmp_hash.each_pair do |key, value|
          result << SimpleMetrics::DataPoint::Counter.new(:name => name, :ts => key, :value => value)
        end
        result
      end
    end

    class Gauge < Base
      def aggregate(dps, name = nil)
        tmp_hash = ts_hash_aggregated(dps) do |value1, value2|
          (value1 + value2)/2
        end

        result = []
        tmp_hash.each_pair do |key, value|
          result << SimpleMetrics::DataPoint::Gauge.new(:name => name, :ts => key, :value => value)
        end
        result
      end
    end

    class Timing < Base
    end

    class Event < Base
    end

    def aggregate(dps, name = nil)
      raise SimpleMetrics::DataPoint::NonMatchingTypesError if has_non_matching_types?(dps)

      dp = dps.first
      strategy(dp).aggregate(dps, name)
    end

    private

    def strategy(dp)
      if dp.counter?
        Counter.new
      elsif dp.gauge?
        Gauge.new
      elsif dp.timing?
        Timing.new
      elsif dp.event?
        Event.new
      end
    end

    def has_non_matching_types?(dps)
      dps.group_by { |dp| dp.type }.size != 1
    end
  end
end