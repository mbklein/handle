require "handle/permissions"
require "handle/record"
require "handle/field"
require "handle/field/admin"

module Handle
  HOME = ENV['HDL_HOME'] || File.expand_path('../../vendor/handle',__FILE__)

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
  class NotFound < HandleError; end
end
