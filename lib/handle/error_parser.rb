module Handle
  # Parses raw messages from hdl-genericbatch and returns a useful message if
  # the line is an error message.
  module ErrorParser

    def self.failure_message(line)
      (status, raw_message) = line.scan(/^=+>(.+)\[[0-9]+\]: (.+)/).flatten
      return unless status == 'FAILURE'
      raw_message.split(/:\s*/).last
    end

  end
end
