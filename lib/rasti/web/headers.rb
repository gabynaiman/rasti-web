module Rasti
  module Web
    class Headers

      CONTENT_TYPES = {
        text: 'text/plain',
        html: 'text/html',
        json: 'application/json',
        js:   'application/javascript',
        css:  'text/css'
      }

      class << self

        CONTENT_TYPES.each do |key, value|
          define_method "for_#{key}" do |charset:'utf-8'|
            content_type value, charset: charset
          end
        end

        def for_file(filename, attachment:true, charset:'utf-8')
          merge content_type(MIME::Types.of(filename).first.content_type, charset: charset),
                content_disposition(filename, attachment: attachment)
        end

        private

        def content_type(type, charset:'utf-8')
          {'Content-Type' => "#{type}; charset=#{charset}"}
        end

        def content_disposition(filename, attachment:true)
          args = []
          args << 'attachment' if attachment
          args << "filename=\"#{File.basename(filename)}\""
          {'Content-Disposition' => args.join("; ")}
        end

        def merge(*poperties)
          poperties.inject({}) do |result, prop|
            result.merge prop
          end
        end

      end
    end
  end
end