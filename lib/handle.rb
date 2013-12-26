require "handle/permissions"
require "handle/record"
require "handle/field"
require "handle/field/admin"

module Handle
  if Module.const_defined? 'JRuby'
    require 'handle/java'
    Record.send(:include, Handle::Java::Persistence)
  else
    require 'handle/command'
    Record.send(:include, Handle::Command::Persistence)
  end
  persistence_module = Module.const_defined?('JRuby') ? 'java' : 'command'
  require "handle/#{persistence_module}"
  Record.send(:include, Handle::Persistence)
  class HandleError < Exception
    def initialize msg=nil
      unless msg.nil?
        msg = msg[0] + msg[1..-1].downcase
      end
      super msg
    end
  end
end
