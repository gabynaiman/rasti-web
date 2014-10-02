module Rasti
  module Web
    class Render

      attr_reader :request, :response, :view_context

      def initialize(request, response)
        @request = request
        @response = response
        @view_context = ViewContext.new request, response
      end

      def status(status, *args)
        respond_with status, 
                     extract_headers(args), 
                     extract_body(args)
      end

      def text(text, *args)
        respond_with extract_status(args), 
                     extract_headers(args).merge('Content-Type' => 'text/plain'), 
                     text
      end

      def html(html, *args)
        respond_with extract_status(args), 
                     extract_headers(args).merge('Content-Type' => 'text/html'), 
                     html
      end

      def json(object, *args)
        respond_with extract_status(args), 
                     extract_headers(args).merge('Content-Type' => 'application/json'), 
                     object.is_a?(String) ? object : JSON.dump(object)
      end

      def js(script, *args)
        respond_with extract_status(args), 
                     extract_headers(args).merge('Content-Type' => 'application/javascript'), 
                     script
      end

      def partial(template, locals={})
        response['Content-Type'] = 'text/html'
        response.write view_context.render(template, locals)
      end

      def view(template, locals={}, layout=nil)
        partial = view_context.render template, locals
        layout = view_context.render(layout || Web.default_layout) { partial }
        
        response['Content-Type'] = 'text/html'
        response.write layout
      end

      private

      def respond_with(status, headers, body)
        response.status = status if status
        response.headers.merge! headers
        response.write body if body
      end

      def extract_status(args)
        args.detect { |a| a.is_a? Fixnum }
      end

      def extract_headers(args)
        args.detect { |a| a.is_a? Hash } || {}
      end

      def extract_body(args)
        args.detect { |a| a.is_a? String }
      end

    end
  end
end