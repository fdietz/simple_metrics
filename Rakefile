require "bundler/gem_tasks"
require 'rake'
require 'rspec/core/rake_task'

require 'simple_metrics'

RSpec::Core::RakeTask.new 
task :default  => :spec
task :test  => :spec

namespace :simple_metrics do

  desc "Ensure collections and index exist"
  task :ensure_collections_exist do
    SimpleMetrics.logger = Logger.new($stdout)
    SimpleMetrics::DataPointRepository.ensure_collections_exist
  end

  desc "Truncate all collections"
  task :truncate_collections do
    SimpleMetrics.logger = Logger.new($stdout)
    SimpleMetrics::DataPointRepository.truncate_collections
  end

end