module SimpleMetrics
  module DataPoint
    extend self

    class NonMatchingTypesError < Exception; end
    class ParserError           < Exception; end
    class UnknownTypeError      < Exception; end

    # examples:
    # com.example.test1:1|c
    # com.example.test2:-1|c
    # com.example.test2:50|g
    # com.example.test3:5|c|@0.1
    # com.example.test4:44|ms
    REGEXP = /^([\d\w_.]*):(-?[\d]*)\|(c|g|ms){1}(\|@([.\d]+))?$/i

    def parse(str)
      if str =~ REGEXP
        name, value, type, sample_rate = $1, $2, $3, $5
        build(:name => name, :value => value, :type => type, :sample_rate => sample_rate)
      else
        raise ParserError, "Parser Error - Invalid data point: #{str}"
      end
    end

    def build(attributes)
      case attributes[:type]
      when 'c'
        DataPoint.create_counter(attributes)
      when 'g'
        Gauge.new(attributes) 
      when 'ms'
        Timing.new(attributes)
      when 'ev'
        Event.new(attributes)
      else
        raise UnknownTypeError, "Unknown Type Error: #{attributes[:type]}"
      end
    end

    def create_counter(attributes)
      Counter.new(attributes)
    end

    def create_gauge(attributes)
      Gauge.new(attributes) 
    end

    def create_timing(attributes)
      Timing.new(attributes)
    end

    def ts_hash(query_result)
      query_result.inject({}) { |result, dp| result[dp.ts] = dp; result }
    end
    
  end
end