require 'simplecov'
SimpleCov.start
require 'handle'

def on_jruby &block
  yield if Module.const_defined? 'JRuby'
end

def on_cruby &block
  yield unless Module.const_defined? 'JRuby'
end