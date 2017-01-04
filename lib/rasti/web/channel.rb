module Rasti
  module Web

    class Channel

      attr_reader :id

      def initialize(id)
        @id = id
        @subscriptions = {}
        @mutex = Mutex.new
      end

      def subscribe
        stream = Stream.new
        
        subscription_id = broadcaster.subscribe id do |message|
          if stream.open?
            stream.write message
          else
            sid = mutex.synchronize { subscriptions.delete stream }
            broadcaster.unsubscribe sid
          end
        end

        mutex.synchronize { subscriptions[stream] = subscription_id }

        stream
      end

      def publish(message)
        broadcaster.publish id, message
      end

      def self.broadcaster
        @broadcaster ||= Broadcaster.new id: Web.channels_prefix, logger: Web.logger
      end

      def self.[](id)
        @channels ||= Hash.new { |h,k| h[k] = self.new k }
        @channels[id]
      end

      private

      attr_reader :subscriptions, :mutex

      def broadcaster
        self.class.broadcaster
      end

    end
  end
end