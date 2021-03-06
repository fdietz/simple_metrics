# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "simple_metrics/version"

Gem::Specification.new do |s|
  s.name        = "simple_metrics"
  s.version     = SimpleMetrics::VERSION
  s.authors     = ["Frederik Dietz"]
  s.email       = ["fdietz@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{SimpleMetrics}
  s.description = %q{SimpleMetrics}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rr"
  s.add_development_dependency "shotgun"
  s.add_development_dependency "rack-test"

  s.add_dependency "eventmachine", ">= 1.0.0.beta.4"
  s.add_dependency "daemons"
  s.add_dependency "mongo", '~> 1.6'
  s.add_dependency "bson", '~> 1.6'
  s.add_dependency "bson_ext", '~> 1.6'
  s.add_dependency "activesupport"
end
