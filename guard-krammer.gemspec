# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "guard/guard-krammer/version"

Gem::Specification.new do |s|
  s.name        = "guard-krammer"
  s.version     = Guard::Krammer::VERSION
  s.authors     = ["Darren Wallace"]
  s.email       = ["wallace@midweekcrisis.com"]
  s.homepage    = ""
  s.summary     = %q{Markdown folder > html folder conversion}
  s.description = %q{Watches a source folder and converts markdown docs to html docs in a target folder}

  s.rubyforge_project = "guard-krammer"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]  


end
