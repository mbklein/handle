module Handle
  module Field
    class HSAdmin < Base
      value_type 'HS_ADMIN'
      default_index 100

      attr_accessor :admin_handle
      attr :admin_perms, :admin_index

      def initialize(handle=nil)
        super()
        @admin_handle = handle
        @admin_index = 300
        @admin_perms = Handle::Permissions.new(
          :add_handle, :delete_handle, :add_na, :delete_na, 
          :modify_values, :remove_values, :add_values, :read_values, 
          :modify_admin, :remove_admin, :add_admin, :list_handles, 
        )
        @admin_perms.bitmask = 0b111111111111
      end

      def value
        values = [self.admin_perms.bitmask, 0, 13, self.admin_handle, 0, self.admin_index]
        values.pack('nnnZ*cn')
      end

      def value_str
        [self.admin_index,self.admin_perms.to_s,self.admin_handle].join(':')
        #value.bytes.collect { |b| '%2.2X' % b }.join('')
      end

      def value=(bytes)
        if bytes =~ /^[0-9A-Fa-f]+$/
          bytes = bytes.scan(/../).map(&:hex).pack('C*')
        end
        values = bytes.unpack('nnnZ*cn')
        self.admin_perms.bitmask = values[0]
        self.admin_handle = values[3]
        self.admin_index = values[5] unless values[5].nil? or values[5] == 0
      end

      def to_h
        result = super.merge({
          admin_handle: self.admin_handle,
          admin_index:  self.admin_index,
          admin_perms:  self.admin_perms.bitmask
        })
        result.delete(:value)
        result
      end      

      def to_s
        " index=#{self.index} type=#{self.class.value_type} ttl=#{self.ttl} perms=#{self.perms} value=#{value_str.inspect}"
      end

      def admin_index=(value)
        @admin_index = value.to_i
      end

      def merge!(hash)
        hash.each_pair do |key,value|
          k = key.to_sym
          self.perms.bitmask = value if k == :perms
          self.admin_perms.bitmask = value if k == :admin_perms
          if [:admin_handle, :admin_index, :index, :ttl, :value].include? k
            self.send(:"#{k.to_s}=", value)
          end
        end
        self
      end
    end
  end
end