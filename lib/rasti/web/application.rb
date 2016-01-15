module Rasti
  module Web
    class Application
      class << self

        Router::VERBS.each do |verb|
          define_method verb do |*args, &block|
            router.public_send verb, *args, &block
          end
        end

        def not_found(*args, &block)
          router.not_found *args, &block
        end

        def use(*args, &block)
          rack.use *args, &block
        end

        def map(path, endpoint=nil, &block)
          rack.map path do
            run endpoint || Endpoint.new(&block)
          end
        end

        def call(env)
          app.call env
        end

        def all_routes
          router.all_routes
        end

        private

        def router
          @router ||= Router.new
        end

        def rack
          @rack ||= Rack::Builder.new
        end

        def app
          @app ||= to_app
        end

        def to_app
          rack.run router
          rack.to_app
        end

      end
    end
  end
end