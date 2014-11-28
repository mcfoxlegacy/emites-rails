# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'emites/version'

Gem::Specification.new do |spec|
  spec.name          = 'emites-rails'
  spec.version       = Emites::VERSION
  spec.authors       = ['José Lopes Neto']
  spec.email         = ['jose.neto@taxweb.com.br']
  spec.summary       = %q{Emites API wrapper gem}
  spec.description   = %q{Encapsulates emites api in a rails gem www.emites.com.br}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_dependency 'httparty','~> 0.13.1'
end
