module Handle
  class Permissions
    attr :bitmask

    def initialize(*flags)
      if flags.last.is_a?(Fixnum)
        @bitmask = flags.pop
      else
        @bitmask = 0
      end
      @flags = Hash[flags.reverse.collect.with_index { |f,i| [f,2**i] }.reverse]
    end

    def bitmask=(value)
      @bitmask = value.to_i
    end

    def method_missing(sym, *args)
      flag = sym.to_s.sub(/([\?\=])$/,'').to_sym
      if @flags.include?(flag)
        case $1
        when '?' then read(flag)
        when '=' then write(flag,args.first)
        else super(sym, *args)
        end
      else
        super(sym, *args)
      end
    end

    def to_bool
      @flags.keys.collect { |flag| read(flag) }
    end

    def to_s
      "%#{@flags.length}.#{@flags.length}b" % bitmask
    end

    def max
      2**@flags.length-1
    end

    def read(flag)
      self.bitmask & @flags[flag] > 0
    end

    def write(flag, value)
      mask = @flags[flag]
      if value
        self.bitmask |= mask
      else
        self.bitmask &= (max - mask)
      end
    end

    def inspect
      str = @flags.keys.select { |flag| self.read(flag) }.collect { |flag| flag.inspect }.join(', ')
      "[#{str}]"
    end
  end
end