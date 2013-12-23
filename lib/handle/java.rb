require 'java'
# Load all jarfiles in $HDL_HOME/lib
hdl_home = ENV['HDL_HOME'] || '/usr/local/handle'
Dir[File.join(hdl_home,'lib','*.jar')].each { |f| require f }

module Handle
  module Java
    module Native
      include_package 'net.handle.hdllib'
      java_import     'net.handle.api.HSAdapterFactory'
    end
  end
end

require 'handle/java/connection'
require 'handle/java/persistence'
