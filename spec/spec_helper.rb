require "simple_metrics"

RSpec.configure do |config|
  config.mock_with :rr
end

SimpleMetrics.logger = Logger.new('/dev/null')
SimpleMetrics.db_config = { :host => 'localhost', :prefix => 'test' }


