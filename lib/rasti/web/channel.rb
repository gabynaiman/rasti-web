module Rasti
  module Web
    class Channel

      attr_reader :streams

      def initialize(id)
        @mutex = Mutex.new
        @channel = Restruct::Channel.new id: Restruct::Id[Web.channels_prefix][id]
        @streams = []
        listen
      end

      def subscribe
        Stream.new.tap do |stream|
          mutex.synchronize do
            streams << stream
          end
        end
      end

      def publish(message)
        channel.publish message
      end

      def self.[](id)
        @channels ||= Hash.new { |h,k| h[k] = self.new id }
        @channels[id]
      end

      private

      attr_reader :mutex, :channel

      def listen
        Thread.new do
          channel.subscribe do |message|
            broadcast message
          end
        end
      end

      def broadcast(message)
        mutex.synchronize do
          streams.delete_if(&:closed?)
          Rasti::Web.logger.debug(Channel) { "Broadcasting (#{streams.count} connections) -> #{message}" } unless streams.empty?
          streams.each do |stream|
            stream.write message
          end
        end
      end
      
    end
  end
end