# encoding: utf-8
require "logger"

require "simple_metrics/version"
require "simple_metrics/configuration"
require "simple_metrics/udp_server"
require "simple_metrics/repository"
require "simple_metrics/data_point_repository"
require "simple_metrics/data_point"
require "simple_metrics/data_point/base"
require "simple_metrics/data_point/counter"
require "simple_metrics/data_point/event"
require "simple_metrics/data_point/gauge"
require "simple_metrics/data_point/timing"
require "simple_metrics/importer"
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

  def config
    @@config ||= Configuration.new
  end

  def configure(hash = {}, &block)
    config.configure(hash, &block)
  end

end