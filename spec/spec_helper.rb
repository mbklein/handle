require 'simplecov'

SimpleCov.start do
  add_filter 'spec/'
  coverage_dir Module.const_defined?('JRuby') ? 'coverage/java' : 'coverage/command'
end

require 'handle'

def jruby?
  Module.const_defined? 'JRuby'
end

def on_jruby &block
  yield if jruby?
end

def on_cruby &block
  yield unless jruby?
end
