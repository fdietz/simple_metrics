# encoding: utf-8
module SimpleMetrics
  module DataPoint
    class Base

      attr_accessor :name, :ts, :type, :value

      def initialize(attributes)
        @name        = attributes[:name]
        @value       = attributes[:value]
        @ts          = attributes[:ts]
        @sample_rate = attributes[:sample_rate]
      end

      def counter?
        @type == 'c'
      end

      def gauge?
        @type == 'g'
      end

      def timing?
        @type == 'ms'
      end

      def event?
        @type == 'ev'
      end

      def timestamp
        ts
      end

      def value
        @value.to_i if @value
      end

      def attributes
        { 
          :name  => @name,
          :value => @value,
          :ts    => @ts,
          :type  => @type
        }
      end

    end
  end
end
