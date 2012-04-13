module SimpleMetrics
  module DataPoint
    class Event < Base

      def initialize(attributes)
        super(attributes)
        @type = 'ev'
      end

      def combine(dp)
        raise "Implement me!"
      end
      
    end
  end
end