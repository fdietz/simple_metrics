module SimpleMetrics
  class Instrument

    attr_reader :id, :created_at, :updated_at
    attr_accessor :name, :metrics

    def initialize(attributes)
      @id          = attributes[:id]
      @name        = attributes[:name]
      @created_at  = attributes[:created_at]
      @updated_at  = attributes[:updated_at]
      @metrics     = attributes[:metrics] || []
    end

    def attributes
      { 
        :id          => @id.to_s, # convert bson id to str
        :name        => @name,
        :metrics     => @metrics,
        :created_at  => @created_at,
        :updated_at  => @updated_at
      }
    end

    def to_s
      attributes.to_s
    end
  end
end