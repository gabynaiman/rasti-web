# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rasti/web/version'

Gem::Specification.new do |spec|
  spec.name          = 'rasti-web'
  spec.version       = Rasti::Web::VERSION
  spec.authors       = ['Gabriel Naiman']
  spec.email         = ['gabynaiman@gmail.com']
  spec.summary       = 'Web blocks to build robust applications'
  spec.description   = 'Web blocks to build robust applications'
  spec.homepage      = 'https://github.com/gabynaiman/rasti-web'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'rack', '~> 1.0'
  spec.add_dependency 'tilt', '~> 2.0'
  spec.add_dependency 'mime-types', '~> 2.0'
  spec.add_dependency 'class_config', '~> 0.0.2'
  spec.add_dependency 'hash_ext', '~> 0.1'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-colorin', '~> 0.1'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'pry-nav'
  spec.add_development_dependency 'rack-test'
end