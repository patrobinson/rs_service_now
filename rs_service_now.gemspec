# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rs_service_now/version'

Gem::Specification.new do |spec|
  spec.name          = "rs_service_now"
  spec.version       = RsServiceNow::VERSION
  spec.authors       = ["nemski"]
  spec.email         = ["nemski.rabbit@gmail.com"]
  spec.summary       = %q{A Ruby Soap ServiceNow interface.}
  spec.description   = %q{A library for exporting data from ServiceNow}
  spec.homepage      = "https://github.com/nemski/rs_service_now"
  spec.license       = "BSD"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "savon", "~> 2.0"
  spec.add_runtime_dependency "activesupport"
end
