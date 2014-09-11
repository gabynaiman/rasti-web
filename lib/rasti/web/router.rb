module Rasti
  module Web
    class Router

      VERBS = [:delete, :get, :head, :options, :patch, :post, :put].freeze

      def routes
        @routes ||= Hash.new { |h,k| h[k] = [] }
      end

      VERBS.each do |verb|
        define_method verb do |pattern, endpoint=nil, &block|
          routes[verb] << Route.new(normalize(pattern), endpoint || block)
        end
      end

      def route(verb, path)
        routes[verb.downcase.to_sym].detect do |r| 
          r.match? normalize(path)
        end
      end

      private

      def normalize(path)
        return '/' if path.empty?
        return path[0..-2] if path[-1, 1] == '/'
        path
      end

    end
  end
end