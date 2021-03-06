module Rasti
  module Web
    class Router

      VERBS = %w(delete get head options patch post put).freeze

      NOT_FOUND_PATTERN = '/404'

      VERBS.each do |verb|
        define_method verb do |pattern, endpoint=nil, &block|
          routes[verb.upcase] << Route.new(pattern, endpoint, &block)
        end
      end

      def not_found(endpoint=nil, &block)
        @not_found_route = Route.new(NOT_FOUND_PATTERN, endpoint, &block)
      end

      def call(env)
        route = route_for env
        env[ROUTE_PARAMS] = route.extract_params env['PATH_INFO']
        route.call env
      end

      def all_routes
        Hash[routes.map { |m,r| [m, r.map(&:pattern)] }]
      end

      private

      def routes
        @routes ||= Hash.new { |h,k| h[k] = [] }
      end

      def route_for(env)
        routes[env['REQUEST_METHOD'].upcase].detect { |r| r.match? env['PATH_INFO'] } || not_found_route
      end

      def not_found_route
        @not_found_route ||= Route.new NOT_FOUND_PATTERN do |request, response, render|
          render.status 404, "Not found: #{request.request_method} #{request.path_info}"
        end
      end

    end
  end
end