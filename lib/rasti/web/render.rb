module Rasti
  module Web
    class Render

      attr_reader :request, :response, :view_context

      def initialize(request, response)
        @request = request
        @response = response
        @view_context = ViewContext.new request, response
      end

      def view(template, locals={}, layout=nil)
        response['Content-Type'] = 'text/html'
        partial = view_context.render template, locals
        response.write view_context.render(layout || Web.default_layout) { partial }
      end

      def partial(template, locals={})
        response['Content-Type'] = 'text/html'
        response.write view_context.render(template, locals)
      end

      def json(object)
        response['Content-Type'] = 'application/json'
        response.write object.is_a?(String) ? object : JSON.dump(object)
      end

      def js(script)
        response['Content-Type'] = 'application/javascript'
        response.write script
      end

      def html(html)
        response['Content-Type'] = 'text/html'
        response.write html
      end

      def text(text)
        response['Content-Type'] = 'text/plain'
        response.write text
      end

      def status(status, text=nil, headers={})
        response.status = status
        response.write text if text
        headers.each do |k,v|
          response[k] = v
        end
      end

    end
  end
end