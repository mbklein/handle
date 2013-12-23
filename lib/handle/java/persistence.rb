module Handle
  module Java
    module Persistence
      attr_reader :handle
      attr_accessor :connection

      def to_java
        result = self.collect do |field|
          perm_params = field.perms.to_bool
          Native::HandleValue.new(field.index.to_java(:int), field.class.value_type.to_java_bytes, 
            field.value.to_java_bytes, Native::HandleValue::TTL_TYPE_RELATIVE.to_java(:byte), 
            field.ttl.to_java(:int), 0.to_java(:int), nil, *perm_params)
        end
        result.to_java(Native::HandleValue)
      end

      def reload
        self.initialize_with(connection.resolve_handle(self.handle).fields)
      end

      def save(new_handle=nil)
        save_handle = new_handle || self.handle
        if save_handle.nil?
          raise "No handle provided."
        end

        if save_handle == self.handle
          original = connection.resolve_handle(save_handle)
          actions = original | self
          actions.each_value { |v| v.connection = connection }
          [:delete,:update,:add].each do |action|
            unless actions[action].empty?
              connection.send("#{action}_handle_values".to_sym, save_handle, actions[action])
            end
          end
        else
          connection.create_handle(save_handle, self)
          @handle = new_handle
        end
        self
      end

      def destroy
        connection.delete_handle(self.handle)
      end
    end
  end
end

