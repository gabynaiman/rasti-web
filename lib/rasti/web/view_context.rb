module Rasti
  module Web
    class ViewContext

      attr_reader :request, :response

      def initialize(request, response)
        @request = request
        @response = response
      end

    end
  end
end