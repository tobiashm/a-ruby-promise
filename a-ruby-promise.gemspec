# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'promise/version'

Gem::Specification.new do |spec|
  spec.name          = "a-ruby-promise"
  spec.version       = Promise::VERSION
  spec.authors       = ["Tobias Haagen Michaelsen"]
  spec.email         = ["tobias.michaelsen@gmail.com"]
  spec.summary       = %q{Promises in Ruby}
  spec.description   = %q{A Ruby Promise implementation that attempts to comply with the Promises/A+ specification and test suite.}
  spec.homepage      = "https://github.com/tobiashm"
  spec.license       = "MIT"

  spec.files         = Dir["{lib,spec}/**/*.rb"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "guard"
end
