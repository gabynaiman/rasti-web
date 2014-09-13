module Rasti
  module Web
    class Application

      def self.router
        @router ||= Router.new
      end

      Router::VERBS.each do |verb|
        define_singleton_method verb do |*args, &block|
          router.public_send verb, *args, &block
        end
      end

      def self.use(*args, &block)
        rack.use *args, &block
      end

      def self.map(path, endpoint=nil, &block)
        rack.map path do
          run endpoint || Endpoint.new(&block)
        end
      end

      def self.new
        rack.run allocate
        rack
      end

      def call(env)
        route = self.class.router.route env['REQUEST_METHOD'], env['PATH_INFO']
        if route
          env['rack.path_params'] = route.extract_params env['PATH_INFO']
          route.endpoint.call env
        else
          not_found
        end
      end

      private

      def self.rack
        @rack ||= Rack::Builder.new
      end

      def not_found
        [404, {'Content-Type' => 'text/html'}, ['<h1>Not found</h1>']]
      end

    end
  end
end