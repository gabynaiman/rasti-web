module Rasti
  module Web
    class Router

      VERBS = %w(delete get head options patch post put).freeze

      NOT_FOUND_PATTERN = '/404'

      VERBS.each do |verb|
        define_method verb do |pattern, endpoint=nil, &block|
          routes[verb] << Route.new(pattern, endpoint, &block)
        end
      end

      def not_found(endpoint=nil, &block)
        @not_found_route = Route.new(NOT_FOUND_PATTERN, endpoint, &block)
      end

      def route_for(verb, path)
        routes[verb.downcase].detect { |r| r.match? path } || not_found_route
      end

      private

      def routes
        @routes ||= Hash.new { |h,k| h[k] = [] }
      end

      def not_found_route
        @not_found_route ||= Route.new NOT_FOUND_PATTERN do |request, response, render|
          render.status 404, "Not found: #{request.request_method} #{request.path_info}"
        end
      end

    end
  end
end