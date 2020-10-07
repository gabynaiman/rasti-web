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
                     extract_headers(args).merge(Headers.for_text),
                     text
      end

      def html(html, *args)
        respond_with extract_status(args),
                     extract_headers(args).merge(Headers.for_html),
                     html
      end

      def json(object, *args)
        respond_with extract_status(args),
                     extract_headers(args).merge(Headers.for_json),
                     object.is_a?(String) ? object : JSON.dump(object)
      end

      def js(script, *args)
        respond_with extract_status(args),
                     extract_headers(args).merge(Headers.for_js),
                     script
      end

      def css(stylesheet, *args)
        respond_with extract_status(args),
                     extract_headers(args).merge(Headers.for_css),
                     stylesheet
      end

      def file(filename, *args)
        respond_with extract_status(args),
                     Headers.for_file(filename).merge(extract_headers(args)),
                     File.read(filename)
      end

      def data(content, *args)
        respond_with extract_status(args),
                     extract_headers(args),
                     content
      end

      def partial(template, locals={})
        response.headers.merge! Headers.for_html
        response.write view_context.render(template, locals)
      end

      def layout(template=nil, &block)
        content = block.call if block
        layout = view_context.render(template || Web.default_layout) { content }

        response.headers.merge! Headers.for_html
        response.write layout
      end

      def view(template, locals={}, layout_template=nil)
        layout(layout_template) { view_context.render template, locals }
      end

      private

      def respond_with(status, headers, body)
        response.status = status if status
        response.headers.merge! headers
        response.write body if body
      end

      def extract_status(args)
        args.detect { |a| a.is_a? Integer }
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