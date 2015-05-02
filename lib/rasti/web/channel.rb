module Rasti
  module Web
    class Channel

      def initialize
        @mutex = Mutex.new
        @streams = []
      end

      def subscribe
        Stream.new.tap do |stream|
          @mutex.synchronize do
            @streams << stream
          end
        end
      end

      def publish(message)
        @mutex.synchronize do
          @streams.delete_if(&:closed?)
          Rasti::Web.logger.debug(Channel) { "Publish (#{@streams.count} connections) -> #{message}" }
          @streams.each do |stream|
            stream.write message
          end
        end
      end
      
    end
  end
end