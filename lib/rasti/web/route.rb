module Rasti
  module Web
    class Route

      attr_reader :pattern, :endpoint, :regexp, :params
      
      def initialize(pattern, endpoint=nil, &block)
        @pattern = normalize pattern
        @endpoint = endpoint || Endpoint.new(&block)
        compile
      end

      def match?(path)
        !regexp.match(normalize(path)).nil?
      end

      def extract_params(path)
        result = regexp.match path
        result ? Hash[params.zip(result.captures)] : {}
      end

      private 

      def compile
        @params = []
        regexp = pattern.gsub(/(:\w+)/) do |match| 
          @params << match[1..-1]
          "([^/?#]+)"
        end
        @regexp = %r{^#{regexp}$}
      end

      def normalize(path)
        return '/' if path.strip.empty? || path == '/'
        return path[0..-2] if path[-1, 1] == '/'
        path
      end

    end
  end
end