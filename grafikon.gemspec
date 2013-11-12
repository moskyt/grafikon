# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grafikon/version'

Gem::Specification.new do |spec|
  spec.name          = "grafikon"
  spec.version       = Grafikon::VERSION
  spec.authors       = ["Frantisek Havluj"]
  spec.email         = ["http://orf.ujv.cz"]
  spec.description   = %q{Grafikon}
  spec.summary       = %q{Simple plotting tool producing Pgfplots source or Gnuplot script}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "guttapercha", '~>0.2.0'
end
