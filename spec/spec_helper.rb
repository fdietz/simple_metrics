require "simple_metrics"
require "rspec"

RSpec.configure do |config|
  config.mock_with :rr
end

SimpleMetrics.logger = Logger.new('/dev/null')
SimpleMetrics.configure do |config|
  config.db = { :host => 'localhost', :prefix => 'test', :options => {} }
end