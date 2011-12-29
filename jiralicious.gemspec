# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jiralicious/version"

Gem::Specification.new do |s|
  s.name        = "jiralicious"
  s.version     = Jiralicious::VERSION
  s.platform    = Gem::Platform::RUBY
  s.homepage = "http://github.com/jstewart/jiralicious"
  s.license = "MIT"
  s.summary = %Q{A Ruby library for interacting with JIRA's REST API}
  s.description = %Q{A Ruby library for interacting with JIRA's REST API}
  s.email = "jstewart@fusionary.com"
  s.authors = ["Jason Stewart"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  s.add_runtime_dependency 'httparty', '~>0.7.8'
  s.add_runtime_dependency 'hashie', '~>1.1'
  s.add_runtime_dependency 'json', '~>1.6.3'
  s.add_development_dependency 'rspec', '~>2.6.0'
  s.add_development_dependency 'fakeweb', '~>1.3.0'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
