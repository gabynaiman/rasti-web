module Rasti
  module Web
    class Request < Rack::Request

      def initialize(env)
        super

        if self.POST.empty?
          json = body.gets
          body.rewind
          params.merge! JSON.parse(json) if json
        end
        params.merge! env[PATH_PARAMS] if env[PATH_PARAMS]
      end

    end
  end
end