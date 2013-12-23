module Handle
  class Record
    attr :fields

    def self.from_data(data)
      result = self.new
      if data.is_a?(String)
        data.lines.each { |line| result << Handle::Field::Base.from_data(line) }
      else
        data.each { |field| result << Handle::Field::Base.from_data(field) }
      end
      result
    end

    def initialize(fields=[])
      initialize_with(fields)
    end

    def initialize_with(fields)
      @fields = fields
    end

    def to_a
      @fields
    end

    def to_json *args
      to_a.to_json *args
    end

    def to_s
      fields.collect(&:to_s).join("\n")
    end

    def <<(field)
      fields << field if field.kind_of?(Handle::Field::Base)
    end

    def add(field_type, value=nil)
      field = Handle::Field.const_get(field_type).new
      indexed_fields = fields.select { |f| f.index < 100 }.sort { |a,b| b.index <=> a.index }
      if indexed_fields.empty?
        field.index = 1
      else
        field.index = indexed_fields.first.index + 1
      end
      field.value = value
      fields << field
      field
    end

    def find_by_index(index)
      self.find { |field| field.index == index }
    end

    def |(other)
      result = { add: Record.new, update: Record.new, delete: Record.new }
      my_ixs = self.collect(&:index).sort
      other.each do |field|
        if my_ixs.delete(field.index)
          result[:update] << field
        else
          result[:add] << field
        end
      end
      my_ixs.each { |ix| result[:delete] << self.find_by_index(ix) }
      result
    end

    def method_missing(sym, *args, &block)
      if @fields.respond_to?(sym)
        @fields.send(sym, *args, &block)
      else
        super
      end
    end
  end
end
