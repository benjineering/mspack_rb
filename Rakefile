require 'bundler/gem_tasks'
require 'rake/extensiontask'
require 'rspec/core/rake_task'

spec = Gem::Specification.load('mspack.gemspec')

Rake::ExtensionTask.new('mspack_native')

RSpec::Core::RakeTask.new(:spec)

task default: [ :clean, :compile, :spec ]
