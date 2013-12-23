module Handle
  module Java
    class Connection
      # A more Ruby-ish HSAdapter

      def initialize(handle, index, *auth)
        # accept either a key file or the key itself
        if auth.length == 2 and (not auth[0].bytes.to_a.include?(0)) and File.exists?(auth[0])
          auth[0] = File.read(auth[0])
        end
        auth_params = auth.collect { |p| p.to_java_bytes }
        protect {
          @conn = Native::HSAdapterFactory.new_instance(handle, index, *auth_params)
        }
      end

      def add_handle_values(handle, record)
        protect {
          @conn.addHandleValues(handle, record.to_java)
        }
      end

      def create_handle(handle, record)
        protect {
          @conn.createHandle(handle, record.to_java)
        }
      end

      def create_record(handle)
        result = Handle::Record.new
        result.connection = self
        result
      end

      def delete_handle(handle)
        protect {
          @conn.deleteHandle(handle)
        }
      end

      def delete_handle_values(handle, record)
        protect {
          @conn.deleteHandleValues(handle, record.to_java)
        }
      end

      def resolve_handle(handle, types=[], indexes=[], auth=true)
        protect {
          java_response = @conn.resolveHandle(
            handle, types.to_java(:string), 
            indexes.to_java(:int), auth
          )
          result = Handle::Record.from_data(java_response)
          result.connection = self
          result.instance_variable_set(:@handle,handle)
          result
        }
      end

      def use_udp=(value)
        protect {
          @conn.setUseUDP(value)
        }
      end

      def update_handle_values(handle, record)
        protect {
          @conn.updateHandleValues(handle, record.to_java)
        }
      end

      def native
        @conn
      end

      protected
      def protect
        begin
          response = yield
        rescue Native::HandleException => err
          exception = Handle::HandleError.new err.message
          exception.set_backtrace(caller)
          raise exception
        end
        response.nil? ? true : response
      end
    end
  end
  Connection = Java::Connection
end
