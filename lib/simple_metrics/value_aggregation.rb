module SimpleMetrics
  module ValueAggregation
    extend self

    class Base
      def aggregate(dps)
        raise "subclass must implement me!"
      end
    end

    class Counter < Base
      def aggregate(dps)
        dps.map { |dp| dp.value }.inject(0) { |result, value| result += value }
      end
    end

    class Gauge < Base
      def aggregate(dps)
        total_value = dps.map { |dp| dp.value }.inject(0) { |result, value| result += value }
        total_value / dps.size
      end
    end

    class Timing < Base
      def aggregate(dps)
        # TODO implement timing
      end
    end

    class Event < Base
      def aggregate(dps)
        # TODO implement event
      end
    end

    def aggregate(dps, name = nil)
      raise SimpleMetrics::DataPoint::NonMatchingTypesError if has_non_matching_types?(dps)

      dp       = dps.first.dup
      dp.name  = name if name
      dp.value = strategy(dp).aggregate(dps)
      dp
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