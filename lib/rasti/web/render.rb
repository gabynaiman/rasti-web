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

      def css(stylesheet, *args)
        respond_with extract_status(args), 
                     extract_headers(args).merge('Content-Type' => 'text/css; charset=utf-8'), 
                     stylesheet
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

      def char_stream(chars, headers={}, chunk_size=5000)
        stream(headers, chunk_size) do |streamer|
          streamer.stream_chars(chars)
        end
      end

      def json_object_stream(json_object, headers={}, chunk_size=5000)
        json_stream(headers, chunk_size) do |streamer|
          streamer.stream_json_object(json_object)
        end
      end

      def json_array_stream(json_objects, headers={}, chunk_size=5000)
        json_stream(headers, chunk_size) do |streamer|
          streamer.stream_json_array(json_objects)
        end
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

      def stream(headers={}, chunk_size=5000)
        headers.merge(headers_for_streaming).each do |k, v|
          response[k] = v
        end

        response.body = Enumerator.new do |yielder|
          yield Streamer.new(yielder, chunk_size)
        end
      end

      def json_stream(headers={}, chunk_size=5000, &block)
        stream(headers.merge(headers_for_json), chunk_size, &block)
      end

      def headers_for_json
        {
          'Content-Type' => 'application/json; charset=utf-8'
        }
      end

      def headers_for_streaming
        {
          'X-Accel-Buffering' => 'no', # Stop NGINX from buffering
          'Cache-Control' => 'no-cache' # Stop downstream caching
        }
      end

      class Streamer
        def initialize(stream, chunk_size)
          @stream = stream
          @chunk_size = chunk_size
        end

        def stream_chars(chars_or_string)
          chars = chars_or_string.is_a?(String) ? chars_or_string.each_char : chars_or_string
          chars.each_slice(chunk_size).each do |cs|
            stream << cs.join
          end
        end

        def stream_json_object(json_object)
          json_string = json_object.is_a?(String) ? json_object : JSON.dump(json_object)
          stream_chars(json_string)
        end

        def stream_json_array(json_objects)
          is_first = true

          json_objects.each do |json_object|
            json_string = json_object.is_a?(String) ? json_object : JSON.dump(json_object)
            prefix = is_first ? '[' : ','
            stream_chars("#{prefix}#{json_string}")
            is_first = false
          end

          missing_chars = is_first ? '[]' : ']'
          stream_chars(missing_chars)
        end

        private

        attr_reader :stream, :chunk_size
      end
    end
  end
end