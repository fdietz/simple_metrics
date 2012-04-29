require 'yaml'

module SimpleMetrics
  class Configuration

    attr_reader :config

    def initialize(hash = {}, &block)
      @config = load_defaults.merge(hash.symbolize_keys)  
    end

    def configure(hash = {}, &block)
      yield self if block_given?
      self
    end

    def db
      @db ||= config.fetch(:db)
    end

    def db=(db)
      @db = db
    end

    def buckets
      @buckets ||= begin
        tmp = config.fetch(:buckets)
        tmp.map { |b| b.symbolize_keys}
      end
    end

    def buckets=(buckets)
      @buckets = buckets
    end

    def server
      @server ||= config.fetch(:server)
    end

    def server=(server)
      @server = server
    end

    def web
      @web ||= config.fetch(:web)
    end

    def web=(web)
      @web = web
    end

    private

    def load_defaults
      @config = load_config.symbolize_keys
    rescue Errno::ENOENT # not found error
      logger.info "Creating initial config file: #{config_file}"
      FileUtils.cp(default_config_file, config_file)
      @config = load_config
    end

    def config_file
      File.expand_path('~/.simple_metrics.conf')
    end

    def default_config_file
      File.expand_path('../../../default_config.yml', __FILE__)
    end

    def load_config
      YAML.load_file(config_file)  
    rescue ArgumentError => e
      logger.error "Error parsing config file: #{e}"
    rescue IOError => e
      logger.error "Error reading config file: #{e}"
    end

    def logger
      SimpleMetrics.logger
    end
  end
end