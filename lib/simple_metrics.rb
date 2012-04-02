# encoding: utf-8
require "logger"

require "simple_metrics/version"
require "simple_metrics/client"
require "simple_metrics/udp_server"
require "simple_metrics/data_point_repository"
require "simple_metrics/data_point"
require "simple_metrics/data_point/base"
require "simple_metrics/data_point/counter"
require "simple_metrics/data_point/event"
require "simple_metrics/data_point/gauge"
require "simple_metrics/data_point/timing"
require "simple_metrics/value_aggregation"
require "simple_metrics/array_aggregation"
require "simple_metrics/update_aggregation"
require "simple_metrics/bucket"
require "simple_metrics/graph"
require "simple_metrics/functions"
require "simple_metrics/metric"
require "simple_metrics/metric_repository"
require "simple_metrics/app"

module SimpleMetrics
  extend self
    
  def logger
    @@logger ||= Logger.new(STDOUT)
  end
  
  def logger=(logger)
    @@logger = logger
  end

  CONFIG_DEFAULTS = {
    :host           => 'localhost',
    :port           => 8125,
    :flush_interval => 10
  }.freeze

  def config
    @@config ||= CONFIG_DEFAULTS
  end

  def config=(options)
    @@config = CONFIG_DEFAULTS.merge(options)
  end

  BUCKETS_DEFAULTS = [
    { 
      :name    => 'stats_per_10s',
      :seconds => 10,
      :capped  => true,
      :size    => 100_100_100
    },
    {
      :name    => 'stats_per_1min',
      :seconds => 60,
      :capped  => true,
      :size    => 1_100_100_100
    },
    {
      :name    => 'stats_per_10min',
      :seconds => 600,
      :size    => 0 ,
      :capped  => false
    },
    {
      :name    => 'stats_per_day',
      :seconds => 600*6*24,
      :size    => 0,
      :capped  => false
    }
  ].freeze

  def buckets_config
    @@buckets ||= BUCKETS_DEFAULTS
  end

  def buckets_config=(buckets)
    @@buckets = buckets
  end

  MONGODB_CONFIG_DEFAULTS = {
    :host      => 'localhost',
    :port      => 27017,
    :prefix    => 'development'
  }.freeze

  def db_config=(options)
    @@db_config = MONGODB_CONFIG_DEFAULTS.merge(options)
  end

  def db_config
    @@db_config ||= MONGODB_CONFIG_DEFAULTS
  end

  def db_name
    "simple_metrics_#{db_config[:prefix]}"
  end

  MONGODB_OPTIONS_DEFAULTS = {
    :pool_size => 5, 
    :timeout   => 5
  }.freeze

  def mongodb_options=(options)
    @@mongo_db_options = MONGODB_OPTIONS_DEFAULTS.merge(options)
  end

  def mongodb_options
    @@mongo_db_options ||= MONGODB_OPTIONS_DEFAULTS
  end

end
