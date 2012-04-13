module SimpleMetrics
  module DataPoint
    class Counter < Base

      def initialize(attributes)
        super(attributes)
        @type = 'c'
        @value = (@value.to_i || 1) * (1.0 / (@sample_rate || 1).to_f)
      end

      def combine(dp)
        @total += 1
        @value += dp.value
        @sum   += dp.value  
        self
      end

    end
  end
end