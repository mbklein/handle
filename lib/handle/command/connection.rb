require 'tempfile'

module Handle
  module Command
    HDL_HOME = ENV['HDL_HOME'] || '/usr/local/handle'

    class Batch
      def initialize(handle, index, auth)
        @batch_file = Tempfile.new('hdl') 
        auth_type = auth.length == 2 ? "PUBKEY" : "SECKEY"
        @batch_file.puts "AUTHENTICATE #{auth_type}:#{index}:#{handle}"
        @batch_file.puts auth.select { |p| not (p.nil? or p.empty?) }.join('|')
      end

      def cleanup
        @batch_file.close unless @batch_file.closed?
        @batch_file.unlink
      end

      def execute!
        @batch_file.close
        cmd = File.join(HDL_HOME, 'bin', 'hdl-genericbatch')
        output = `#{cmd} #{@batch_file.path} 2>/dev/null`
        results = output.lines.select { |line| line =~ /^=+>/ }
        results.each do |rs|
          (status, message) = rs.scan(/^=+>(.+)\[[0-9]+\]: (.+)/).flatten
          (action, handle, code, message) = message.split(/:\s*/,4)
          if status == 'FAILURE'
            exception = Handle::HandleError.new message
            exception.set_backtrace(caller[3..-1])
            raise exception
          end
        end
        return true
      end

      def add_handle_values(handle, record)
        @batch_file.puts "\nADD #{handle}"
        @batch_file.puts record.to_batch
      end

      def create_handle(handle, record)
        @batch_file.puts "\nCREATE #{handle}"
        @batch_file.puts record.to_batch
      end

      def delete_handle(handle)
        @batch_file.puts "\nDELETE #{handle}"
      end

      def delete_handle_values(handle, record)
        indexes = record.collect(&:index).join(',')
        @batch_file.puts "\nREMOVE #{indexes}:#{handle}"
      end

      def update_handle_values(handle, record)
        @batch_file.puts "\nMODIFY #{handle}"
        @batch_file.puts record.to_batch
      end
    end

    class Connection
      def initialize(handle, index, *auth, &block)
        @handle = handle
        @index  = index
        @auth_params = auth
        if block_given?
          batch &block
        end
      end

      def batch
        context = Batch.new(@handle, @index, @auth_params)
        begin
          yield context
          result = context.execute!
        ensure
          context.cleanup
        end
        result
      end

      def add_handle_values(*args)
        batch { |b| b.add_handle_values(*args) }
      end

      def create_handle(*args)
        batch { |b| b.create_handle(*args) }
      end

      def delete_handle(*args)
        batch { |b| b.delete_handle(*args) }
      end

      def delete_handle_values(*args)
        batch { |b| b.delete_handle_values(*args) }
      end

      def update_handle_values(*args)
        batch { |b| b.update_handle_values(*args) }
      end

      def create_record(handle)
        result = Handle::Record.new
        result.connection = self
        result.handle = handle
        result
      end

      def resolve_handle(handle, types=[], indexes=[], auth=true)
        cmd = File.join(HDL_HOME, 'bin', 'hdl-qresolver')
        response = `#{cmd} #{handle} 2>/dev/null`.strip
        if response =~ /^Got Response:/
          response = response.lines.select { |line| line =~ /^\s*index=/ }.join("")
          result = Handle::Record.from_data(response)
          result.connection = self
          result.handle = handle
          result
        else
          (code, message) = response.lines.to_a.last.scan(/Error\(([0-9]+)\): (.+)$/).flatten
          exception_klass = case code.to_i
          when 100 then Handle::NotFound
          else          Handle::HandleError
          end
          exception = exception_klass.new message
          exception.set_backtrace(caller)
          raise exception
        end
      end

    end
  end
  Connection = Command::Connection
end
