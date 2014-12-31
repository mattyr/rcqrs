# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rcqrs/version'

Gem::Specification.new do |spec|
  spec.name          = %q{rcqrs}
  spec.version       = Rcqrs::VERSION
  spec.authors       = ["Ben Smith"]
  spec.email         = %q{ben@slashdotdash.net}
  spec.summary       = %q{CQRS library in Ruby}
  spec.description   = %q{A Ruby implementation of Command-Query Responsibility Segregation (CQRS) with Event Sourcing, based upon the ideas of Greg Young.}
  spec.homepage      = %q{http://github.com/slashdotdash/rcqrs}
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 4.2.0"
  spec.add_dependency "activerecord", "~> 4.2.0"
  spec.add_dependency "eventful", "1.0.1"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1.0"
  spec.add_development_dependency "sqlite3", "~> 1.3.10"
end
