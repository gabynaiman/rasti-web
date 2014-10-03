module Rasti
  module Web
    class Request < Rack::Request

      def initialize(env)
        super
        params.merge! JSON.parse(body_text) if json? && body_text
        params.merge! env[ROUTE_PARAMS] if env[ROUTE_PARAMS]
      end

      def body_text
        @body_text ||= begin 
          text = body.read
          body.rewind
          text
        end
      end

      def json?
        content_type == 'application/json'
      end

    end
  end
end