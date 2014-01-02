# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'handle/version'

Gem::Specification.new do |spec|
  spec.name             = %q{handle-system}
  spec.version          = Handle::VERSION
  spec.authors          = ["Michael Klein"]
  spec.email            = ["mbklein@gmail.com"]
  spec.description      = %q{Ruby classes for interfacing with Handle System servers}
  spec.summary          = %q{Ruby classes for interfacing with Handle System servers}
  #spec.homepage         = %q{http:/github.com/mbklein/handle}
  spec.license          = %q{Apache 2}
  spec.files            = Dir['lib/**/*.rb'] + ['Gemfile','Rakefile']
  spec.test_files       = Dir['spec/**/*.rb']
  spec.extra_rdoc_files = ["LICENSE.txt","README.md"]
  spec.require_paths    = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
