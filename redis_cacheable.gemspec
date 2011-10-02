# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redis_cacheable/version"

Gem::Specification.new do |s|
  s.name        = "redis_cacheable"
  s.version     = RedisCacheable::VERSION
  s.authors     = ["Trevor Rosen"]
  s.email       = ["trevor@catapult-creative.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "redis_cacheable"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
  s.add_runtime_dependency  "activesupport"
  s.add_runtime_dependency  "redis"
  s.add_runtime_dependency  "redis-namespace"
end
