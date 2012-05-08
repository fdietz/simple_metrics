module SimpleMetrics
  class Dashboard

    attr_reader :id, :created_at, :updated_at
    attr_accessor :name, :instruments

    def initialize(attributes)
      @id          = attributes[:id]
      @name        = attributes[:name]
      @created_at  = attributes[:created_at]
      @updated_at  = attributes[:updated_at]
      @instruments = attributes[:instruments] || []
    end

    def attributes
      { 
        :id          => @id.to_s, # convert bson id to str
        :name        => @name,
        :instruments => @instruments,
        :created_at  => @created_at,
        :updated_at  => @updated_at
      }
    end

    def to_s
      attributes.to_s
    end
  end
end