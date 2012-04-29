module SimpleMetrics
  class Dashboard

    attr_reader :id, :name, :created_at, :updated_at

    def initialize(attributes)
      @id          = attributes[:id]
      @name        = attributes[:name]
      @created_at  = attributes[:created_at]
      @updated_at  = attributes[:updated_at]
    end

    def attributes
      { 
        :id          => @id.to_s, # convert bson id to str
        :name        => @name,
        :created_at  => @created_at,
        :updated_at  => @updated_at
      }
    end

    def to_s
      attributes.to_s
    end
  end
end