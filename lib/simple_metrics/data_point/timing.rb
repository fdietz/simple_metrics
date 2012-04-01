module SimpleMetrics
  module DataPoint
    class Timing < Base

      def initialize(attributes)
        super(attributes)
        @type = 'ms'
      end

    end
  end
end