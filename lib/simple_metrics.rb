# encoding: utf-8
require "logger"

require "simple_metrics/version"
require "simple_metrics/client"
require "simple_metrics/server"
require "simple_metrics/data_point"
require "simple_metrics/bucket"
require "simple_metrics/graph"
require "simple_metrics/functions"
require "simple_metrics/mongo"

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
      :seconds => 86400,
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

  MONGODB_DEFAULTS = {
    :pool_size => 5, 
    :timeout   => 5,
    :strict    => true
  }.freeze

  DB_CONFIG_DEFAULTS = {
    :host      => 'localhost',
    :prefix    => 'development'
  }.freeze

  def db_config=(options)
    @@db_config = {
      :host    => options.delete(:host),
      :db_name => "simple_metrics_#{options.delete(:prefix)}",
      :options => MONGODB_DEFAULTS.merge(options)
    }
  end

  def db_config
    @@db_config ||= DB_CONFIG_DEFAULTS.merge(
      :db_name => "simple_metrics_#{DB_CONFIG_DEFAULTS[:prefix]}",
      :options => MONGODB_DEFAULTS
    )
  end

end
