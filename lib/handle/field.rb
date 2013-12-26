module Handle
  module Field
    class Base    
      attr_accessor :value
      attr :index, :ttl, :perms

      class << self
        @@value_types = {}
        def value_type val=nil
          if val
            if @value_type
              @@value_types.delete(@value_type)
            end
            @value_type = val
            @@value_types[val] = self
          end
          @value_type
        end

        def default_index val=nil
          val ? @default_index = val : @default_index
        end

        def from_hash(hash)
          type = hash.values_at(:type,'type').compact.first
          if @@value_types.has_key? type
            klass = @@value_types[type]
            result = klass.new
            result.merge!(hash)
          end
        end

        def from_string(str)
          attrs, perms, data = str.scan(/^\s*(.+) ([10rw\-]+) "(.+)"$/).flatten
          attrs = attrs.split(/\s+/).inject({}) { |hash,attr| 
            (k,v) = attr.split(/\=/,2) 
            hash[k.to_sym] = v
            hash
          }
          type = attrs.delete(:type)
          if @@value_types.has_key? type
            klass = @@value_types[type]
            result = klass.new
            result.merge!(attrs)
            result.perms.bitmask = perms.gsub(/./) { |m| m =~ /[0\-]/ ? '0' : '1' }.to_i(2)
            result.value = data
            result
          else
            nil
          end
        end

        def from_data(data)
          if data.is_a?(Hash)
            self.from_hash(data)
          else
            self.from_string(data.to_s)
          end
        end
      end

      def initialize
        @index = self.class.default_index
        @ttl = 86400
        @perms = Handle::Permissions.new(:admin_read, :admin_write, :public_read, :public_write, 0b1110)
      end

      def ==(other)
        self.to_s == other.to_s
      end

      def index=(value)
        @index = value.to_i
      end

      def ttl=(value)
        @ttl = value.to_i
      end

      def merge!(hash)
        hash.each_pair do |key,value|
          k = key.to_sym
          value = value.to_i if [:perms,:index].include?(k)
          self.perms.bitmask = value if k == :perms
          if [:index, :ttl, :value].include? k
            self.send(:"#{k.to_s}=", value)
          end
        end
        self
      end

      def to_h
        {
          index: self.index,
          type:  self.class.value_type,
          ttl:   self.ttl,
          perms: self.perms.bitmask,
          value: self.value
        }
      end

      def to_json *args
        self.to_h.to_json *args
      end

      def to_s
        " index=#{self.index} type=#{self.class.value_type} ttl=#{self.ttl} #{self.perms} #{self.value.inspect}"
      end

      def value_str
        value.to_s
      end
    end

    class URL      < Base ; value_type 'URL'        ; end
    class URN      < Base ; value_type 'URN'        ; end
    class Email    < Base ; value_type 'EMAIL'      ; end
    class HSSite   < Base ; value_type 'HS_SITE'    ; end
    class HSServ   < Base ; value_type 'HS_SERV'    ; end
    class HSAlias  < Base ; value_type 'HS_ALIAS'   ; end
    class HSPubKey < Base ; value_type 'HS_PUB_KEY' ; default_index 300 ; end
    class HSSecKey < Base ; value_type 'HS_SEC_KEY' ; default_index 301 ; end
    class HSVList  < Base ; value_type 'HS_VLIST'   ; default_index 400 ; end
  end
end