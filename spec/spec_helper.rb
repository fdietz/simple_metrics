require "simple_metrics"
require "rspec"
require "rack/test"

set :environment, :test

RSpec.configure do |config|
  config.mock_with :rr
  config.include Rack::Test::Methods
end

SimpleMetrics.logger = Logger.new('/dev/null')
SimpleMetrics.configure do |config|
  config.db = { :host => 'localhost', :prefix => 'test', :options => {} }
end