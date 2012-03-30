$LOAD_PATH.unshift ::File.expand_path(::File.dirname(__FILE__) + '/lib')

require "rubygems"
require "simple_metrics"

config      = ENV['SIMPLE_METRICS_CONFIG']
config_file = File.expand_path(config)

if config && ::File.exists?(config_file)
  load config_file
end

run SimpleMetrics::App.new