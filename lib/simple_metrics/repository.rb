module SimpleMetrics
  module Repository
    extend self

    def connection
      @@connection ||= ::Mongo::Connection.new(host, port)
    end

    def db
      @@db ||= connection.db(db_name, config.fetch(:options))
    end

    def db_name
      "simple_metrics_#{prefix}"
    end

    def prefix
      config[:prefix] || 'development'
    end
    
    def host
      config[:host] || 'localhost'
    end

    def port
      config[:port] || 27017
    end

    def config
      SimpleMetrics.config.db
    end

  end
end