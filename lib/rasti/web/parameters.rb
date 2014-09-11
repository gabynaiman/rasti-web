module Rasti
  module Web
    class Parameters
      
      def initialize(hash)
        @hash = Hash[hash.map { |k,v| [k.to_s, v] }]
      end

      def [](key)
        value = @hash[key.to_s]
        value.is_a?(Hash) ? Parameters.new(value) : value
      end

      def to_h
        @hash
      end

      def inspect
        @hash.inspect
      end

      def to_s
        @hash.to_s
      end

    end
  end
end