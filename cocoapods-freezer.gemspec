# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-freezer/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-freezer'
  spec.version       = CocoapodsFreezer::VERSION
  spec.authors       = ['ca1md0wn']
  spec.email         = ['studio.ca1md0wn@gmail.com']
  spec.description   = %q{A short description of cocoapods-freezer.}
  spec.summary       = %q{A longer description of cocoapods-freezer.}
  spec.homepage      = 'https://github.com/ca1md0wn/cocoapods-freezer'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency "cocoapods", '1.5.3'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
