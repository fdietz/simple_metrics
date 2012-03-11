module SimpleMetrics
  module DataPoint
    class Event < Base

      class << self
        def aggregrate_value(dps)
          # TODO implement
        end

        def aggregrate_array(dps, name)
          # TODO implement
        end
      end

      def initialize(attributes)
        super(attributes)
        @type = 'ev'
      end

    end
  end
end