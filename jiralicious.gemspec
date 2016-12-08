# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jiralicious/version"

Gem::Specification.new do |s|
  s.name        = "jiralicious"
  s.version     = Jiralicious::VERSION
  s.platform    = Gem::Platform::RUBY
  s.homepage    = "http://github.com/jstewart/jiralicious"
  s.license     = "MIT"
  s.summary     = %(A Ruby library for interacting with JIRA's REST API)
  s.description = %(A Ruby library for interacting with JIRA's REST API)
  s.email       = "jstewart@fusionary.com"
  s.authors     = ["Jason Stewart"]

  s.add_runtime_dependency "crack", "~> 0.1.8"
  s.add_runtime_dependency "hashie", ">= 1.1"
  s.add_runtime_dependency "httparty", ">= 0.10"
  s.add_runtime_dependency "json", ">= 1.6"
  s.add_runtime_dependency "oauth"
  s.add_runtime_dependency "nokogiri"

  s.add_development_dependency "rspec", "~> 3.5"
  s.add_development_dependency "fakeweb", "~> 1.3.0"
  s.add_development_dependency "pry"
  s.add_development_dependency "rake"
  s.add_development_dependency "rubocop"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]
end
