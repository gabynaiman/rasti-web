module Rasti
  module Web
    class Template

      def self.render(template, context, locals={}, &block)
        files = Web.template_engines.map { |e| File.join Web.views_path, "#{template}.#{e}" }
        template_file = files.detect { |f| File.exists? f }

        raise "Missing template #{template} [#{files.join(', ')}]" unless template_file
                                  
        tilt = cache.fetch(template_file) { Tilt.new template_file }
        tilt.render(context, locals, &block)
      end

      private

      def self.cache
        Thread.current[:templates_cache] ||= Tilt::Cache.new
      end
      
    end
  end
end