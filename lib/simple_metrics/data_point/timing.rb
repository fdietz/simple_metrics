module SimpleMetrics
  module DataPoint
    class Timing < Base

      def initialize(attributes)
        super(attributes)
        @type = 'ms'
      end

      def combine(dp)
        raise "Implement me!"
      end
    end
  end
end