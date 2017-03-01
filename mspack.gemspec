# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mspack/version'

Gem::Specification.new do |spec|
  spec.name          = "mspack_rb"
  spec.version       = Mspack::VERSION
  spec.authors       = ["Ben Williams"]
  spec.email         = ["8enwilliams@gmail.com"]

  spec.summary       = 'A ruby gem wrapper for libmspack'
  spec.description   = 'A ruby gem wrapper for libmspack'
  spec.homepage      = 'https://github.com/benjineering/mspack_rb'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions    << 'ext/mspack/extconf.rb'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rake-compiler", "~> 1.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
end
