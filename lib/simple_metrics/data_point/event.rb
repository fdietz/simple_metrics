module SimpleMetrics
  module DataPoint
    class Event < Base

      def initialize(attributes)
        super(attributes)
        @type = 'ev'
      end

    end
  end
end