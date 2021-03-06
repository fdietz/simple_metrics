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
        Counter.new(attributes)
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
    
    def aggregate_values(dps)
      raise SimpleMetrics::DataPoint::NonMatchingTypesError if has_non_matching_types?(dps)

      dp       = dps.first.dup
      dp.value = if dp.counter?
        sum(dps)
      elsif dp.gauge?
        sum(dps) / dps.size
      elsif dp.event?
        raise "Implement me!"
      elsif dp.timing?
        raise "Implement me!"
      else
        raise ArgumentError("Unknown data point type: #{dp}")
      end
      dp
    end

    private

    def sum(dps)
      dps.map { |dp| dp.value }.inject(0) { |result, value| result += value }
    end

    def has_non_matching_types?(dps)
      dps.group_by { |dp| dp.type }.size != 1
    end

  end
end