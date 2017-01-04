module Rasti
  module Web
    class Stream

      TIMEOUT = 0.0001

      def initialize
        @queue = Queue.new
        @closed = false
      end

      def write(message)
        raise 'Closed stream' if closed?
        @queue << message
      end

      def each
        while open?
          message = @queue.pop
          yield message if message
          sleep TIMEOUT
        end
      end

      def close
        @closed = true
      end

      def closed?
        @closed
      end

      def open?
        !closed?
      end

    end
  end
end