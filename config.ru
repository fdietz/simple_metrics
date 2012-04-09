$LOAD_PATH.unshift ::File.expand_path(::File.dirname(__FILE__) + '/lib')

require "rubygems"
require "simple_metrics"

run SimpleMetrics::App.new