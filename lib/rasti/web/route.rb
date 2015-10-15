module Rasti
  module Web
    class Route

      attr_reader :pattern

      def initialize(pattern, endpoint=nil, &block)
        @pattern = normalize pattern
        @endpoint = endpoint || Endpoint.new(&block)
        @regexp = compile
      end

      def match?(path)
        !@regexp.match(normalize(path)).nil?
      end

      def extract_params(path)
        result = @regexp.match path
        result ? result.names.each_with_object({}) { |v,h| h[v] = result[v] } : {}
      end

      def call(env)
        @endpoint.call env
      end

      private

      def compile
        %r{^#{pattern.gsub(')', '){0,1}').gsub(/:[a-z0-9_-]+/) { |var| "(?<#{var[1..-1]}>[^\/?#]+)" }}$}
      end

      def normalize(path)
        return '/' if path.strip.empty? || path == '/'
        return path[0..-2] if path[-1, 1] == '/'
        path
      end

    end
  end
end