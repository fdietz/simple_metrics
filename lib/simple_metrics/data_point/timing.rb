module SimpleMetrics
  module DataPoint
    class Timing < Base

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
        @type = 'ms'
      end

    end
  end
end