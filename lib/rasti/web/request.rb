module Rasti
  module Web
    class Request < Rack::Request

      def params
        @params ||= Hash::Indifferent.new.tap do |hash|
          hash.update self.GET
          hash.update self.POST
          hash.update env[ROUTE_PARAMS] if env.key? ROUTE_PARAMS
          hash.update JSON.parse(body_text) if json? && body_text
        end
      end

      def body_text
        @body_text ||= begin
          text = body.read
          body.rewind
          text
        end
      end

      def json?
        !content_type.nil? && ContentType.parse(content_type).mime_type == 'application/json'
      rescue
        false
      end

    end
  end
end