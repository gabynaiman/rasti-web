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
                     extract_headers(args).merge('Content-Type' => 'text/plain; charset=utf-8'), 
                     text
      end

      def html(html, *args)
        respond_with extract_status(args), 
                     extract_headers(args).merge('Content-Type' => 'text/html; charset=utf-8'), 
                     html
      end

      def json(object, *args)
        respond_with extract_status(args), 
                     extract_headers(args).merge('Content-Type' => 'application/json; charset=utf-8'), 
                     object.is_a?(String) ? object : JSON.dump(object)
      end

      def js(script, *args)
        respond_with extract_status(args), 
                     extract_headers(args).merge('Content-Type' => 'application/javascript; charset=utf-8'), 
                     script
      end

      def file(filename, *args)
        content_type = MIME::Types.of(filename).first.content_type
        body = File.read filename

        respond_with extract_status(args), 
                     extract_headers(args).merge('Content-Type' => content_type), 
                     body
      end

      def partial(template, locals={})
        response['Content-Type'] = 'text/html; charset=utf-8'
        response.write view_context.render(template, locals)
      end

      def layout(template=nil, &block)
        content = block.call if block
        layout = view_context.render(template || Web.default_layout) { content }
        
        response['Content-Type'] = 'text/html; charset=utf-8'
        response.write layout
      end

      def view(template, locals={}, layout_template=nil)
        layout(layout_template) { view_context.render template, locals }
      end

      def server_sent_events(channel)
        response.status = 200
        response['Content-Type']  = 'text/event-stream'
        response['Cache-Control'] = 'no-cache'
        response['Connection']    = 'keep-alive'
        response.body = channel.subscribe
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