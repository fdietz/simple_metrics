# encoding: utf-8
module SimpleMetrics
  module DataPoint
    class Base

      attr_accessor :name, :ts, :type, :value, :total, :sum
      attr_reader :id

      def initialize(attributes)
        @id          = attributes[:id]
        @name        = attributes[:name]
        @value       = attributes[:value]
        @ts          = attributes[:ts]
        @sample_rate = attributes[:sample_rate]
        @sum         = attributes[:sum]
        @total       = attributes[:total]
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
          :type  => @type,
          :total => @total,
          :sum   => @sum
        }
      end

      def to_s
        attributes.to_s
      end
    end
  end
end
