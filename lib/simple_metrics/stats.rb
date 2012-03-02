# encoding: utf-8
module SimpleMetrics

  class Stats

    class NonMatchingTypesError < Exception; end
    class ParserError           < Exception; end

    # examples:
    # com.example.test1:1|c
    # com.example.test2:-1|c
    # com.example.test2:50|g
    # com.example.test3:5|c|@0.1
    # com.example.test4:44|ms
    REGEXP = /^([\d\w_.]*):(-?[\d]*)\|(c|g|ms){1}(\|@([.\d]+))?$/i

    class << self

      def parse(str)
        if str =~ REGEXP
          name, value, type, sample_rate = $1, $2, $3, $5
          if type == "ms"
            # TODO: implement sample_rate handling
            create_timing(:name => name, :value => value)
          elsif type == "g"
            create_gauge(:name => name, :value => (value.to_i || 1) * (1.0 / (sample_rate || 1).to_f) )
          elsif type == "c"
            create_counter(:name => name, :value => (value.to_i || 1) * (1.0 / (sample_rate || 1).to_f) )
          end
        else
          raise ParserError, "Parser Error - Invalid Stat: #{str}"
        end
      end

      def create_counter(attributes)
        Stats.new(attributes.merge(:type => 'c'))
      end

      def create_gauge(attributes)
        Stats.new(attributes.merge(:type => 'g'))
      end

      def create_timing(attributes)
        Stats.new(attributes.merge(:type => 'ms'))
      end

      def aggregate(stats_array)
        raise NonMatchingTypesError unless stats_array.group_by { |stats| stats.type }.size == 1

        result_stat = stats_array.first.dup
        result_stat.value = stats_array.map { |stats| stats.value }.inject(0) { |result, value| result += value }
        result_stat
      end

      def create_from_db(attributes)
        Stats.new(:name => attributes["name"], :value => attributes["value"], :ts => attributes["ts"], :type => attributes["type"])
      end
    end

    attr_accessor :name, :ts, :type, :value

    def initialize(attributes)
      @name  = attributes[:name]
      @value = attributes[:value]
      @ts    = attributes[:ts]
      @type  = attributes[:type]
    end

    def counter?
      type == 'c'
    end

    def gauge?
      type == 'g'
    end

    def timing?
      type == 'ms'
    end

    def timestamp
      ts
    end

    def value
      @value.to_i
    end

    def attributes
      { 
        :name  => name,
        :value => value,
        :ts    => ts,
        :type  => type
      }
    end

  end
end
