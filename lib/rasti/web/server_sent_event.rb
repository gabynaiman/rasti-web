module Rasti
  module Web
    class ServerSentEvent < String

      attr_reader :data, :id, :event

      private

      def initialize(data, options={})
        @data  = data
        @id    = options[:id]
        @event = options[:event]

        super serialize
      end

      def serialize
        serialized_data = data.respond_to?(:to_json) ? data.to_json : data.to_s

        message = ''
        message << "id: #{id}\n" if id
        message << "event: #{event}\n" if event
        serialized_data.split("\n").each do |d|
          message << "data: #{d}\n"
        end
        message << "\n"
      end

    end
  end
end