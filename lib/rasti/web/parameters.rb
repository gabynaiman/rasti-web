module Rasti
  module Web
    class Parameters

      extend Forwardable

      def_delegators :@hash, :inspect, :to_s, :each, :keys, :values
      
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

    end
  end
end