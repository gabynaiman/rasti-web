module Rasti
  module Web
    class Route

      attr_reader :pattern, :endpoint, :regexp, :params
      
      def initialize(pattern, endpoint)
        @pattern = pattern
        @endpoint = endpoint
        compile
      end

      def match?(path)
        !regexp.match(path).nil?
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

    end
  end
end