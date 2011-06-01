# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "guard/krammer/version"

Gem::Specification.new do |s|
  s.name        = "guard-krammer"
  s.version     = Guard::KrammerVersion::VERSION
  s.authors     = ["Darren Wallace"]
  s.email       = ["wallace@midweekcrisis.com"]
  s.homepage    = "http://www.cdsm.co.uk"
  s.summary     = %q{Markdown folder > html folder conversion}
  s.description = %q{Watches a source folder and converts markdown docs to html docs in a target folder}

  s.rubyforge_project = "guard-krammer"

  # s.files         = `git ls-files`.split("\n") # Bundler created line
  s.files        	= Dir.glob('{lib}/**/*') + %w[LICENSE README.md]  # copied from guard examples
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'guard', '>= 0.2.2'
	s.add_dependency 'kramdown', '~> 0.13.3'

  s.add_development_dependency 'bundler', '~> 1.0'
  s.add_development_dependency 'rspec',   '~> 2.5'
end