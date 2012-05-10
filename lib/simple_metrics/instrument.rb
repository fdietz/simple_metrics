module SimpleMetrics
  class Instrument

    attr_accessor :id, :name, :metrics, :renderer, :created_at, :updated_at

    def initialize(attributes)
      @id          = attributes[:id]
      @name        = attributes[:name]
      @renderer    = attributes[:renderer] || 'line'
      @created_at  = attributes[:created_at]
      @updated_at  = attributes[:updated_at]
      @metrics     = attributes[:metrics] || []
    end

    def attributes
      { 
        :id          => @id.to_s, # convert bson id to str
        :name        => @name,
        :renderer    => @renderer,
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