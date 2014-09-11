module Rasti
  module Web
    class Render

      attr_reader :response

      def initialize(response)
        @response = response
      end

      def view(template, locals={}, layout=nil)
        response['Content-Type'] = 'text/html'
        partial = render template, locals
        response.write render(layout || Web.default_layout, content: partial)
      end

      def partial(template, locals={})
        response['Content-Type'] = 'text/html'
        response.write render(template, locals)
      end

      def json(object)
        response['Content-Type'] = 'application/json'
        response.write object.is_a?(String) ? object : JSON.dump(object)
      end

      def js(script)
        response['Content-Type'] = 'application/javascript'
        response.write script
      end

      def text(text)
        response.write text
      end

      private

      def render(template, locals={}, options={}, &block)
        files = Web.template_engines.map { |e| File.join Web.views_path, "#{template}.#{e}" }
        template_file = files.detect { |f| File.exists? f }

        raise "Missing template #{template} [#{files.join(', ')}]" unless template_file
                                  
        tilt = cache.fetch template_file do
          Tilt.new(template_file, options)
        end
        tilt.render(self, locals, &block)
      end

      def cache
        Thread.current[:templates_cache] ||= Tilt::Cache.new
      end

    end
  end
end