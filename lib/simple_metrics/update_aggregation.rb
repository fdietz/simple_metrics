module SimpleMetrics
  module UpdateAggregation
    extend self

    class Base
      def aggregate(existing_dp, dp)
        raise "subclass must implement me!"
      end
    end

    class Counter < Base
      def aggregate(existing_dp, dp)
        existing_dp.total += 1
        existing_dp.value += dp.value
        existing_dp.sum   += dp.value
      end
    end

    class Gauge < Base
      def aggregate(existing_dp, dp)
        existing_dp.total += 1
        existing_dp.sum   += dp.value
        existing_dp.value  = existing_dp.sum / existing_dp.total 
      end
    end

    class Timing < Base
      def aggregate(existing_dp, dp)
        # TODO implement timing
      end
    end

    class Event < Base
      def aggregate(existing_dp, dp)
        # TODO implement event
      end
    end

    def aggregate(existing_dp, dp)
      raise SimpleMetrics::DataPoint::NonMatchingTypesError if existing_dp.type != dp.type
      strategy(existing_dp).aggregate(existing_dp, dp)
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