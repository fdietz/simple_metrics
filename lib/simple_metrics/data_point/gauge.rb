module SimpleMetrics
  module DataPoint
    class Gauge < Base

      def initialize(attributes)
        super(attributes)
        @type = 'g'
        @value = (@value.to_i || 1) * (1.0 / (@sample_rate || 1).to_f)
      end

      def combine(dp)
        @total += 1
        @sum   += dp.value
        @value  = @sum / @total 
        self
      end
    end
  end
end