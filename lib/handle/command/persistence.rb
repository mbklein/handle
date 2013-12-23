module Handle
  module Command
    module Persistence
      attr_reader :handle
      attr_accessor :connection

      def to_batch
        self.collect do |field|
          perm_params = field.perms.to_s
          data_type = case field.class.value_type
          when 'HS_ADMIN'  then 'ADMIN'
          when 'HS_SITE'   then 'FILE'
          when 'HS_PUBKEY' then 'FILE'
          else 'UTF8'
          end
          "#{field.index} #{field.class.value_type} #{field.ttl} #{perm_params} #{data_type} #{field.value_str}"
        end
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

