module Rasti
  module Web
    class ViewContext

      attr_reader :request, :response

      def initialize(request, response)
        @request = request
        @response = response
      end

      def render(template, locals={}, &block)
        Template.render template, self, locals, &block
      end

    end
  end
end