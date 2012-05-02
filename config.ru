$LOAD_PATH.unshift ::File.expand_path(::File.dirname(__FILE__) + '/lib')

require "rubygems"
require "simple_metrics"
require "simple_metrics/app"

map "/assets" do
  run SimpleMetrics::App.sprockets
end

map "/" do
  run SimpleMetrics::App
end
