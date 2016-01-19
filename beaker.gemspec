# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'beaker/version'

Gem::Specification.new do |spec|
  spec.name          = 'beaker'
  spec.version       = Beaker::VERSION
  spec.authors       = ['Anthony Salani']
  spec.email         = ['asalani93@gmail.com']

  spec.summary       = 'A DSL for manipulating spreadsheet-like data.'
  spec.description   = 'A DSL for manipulating spreadsheet-like data.'
  spec.homepage      = 'https://github.com/isenseDev/rSENSE'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rltk'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest'
end
