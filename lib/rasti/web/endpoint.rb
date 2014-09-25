module Rasti
  module Web
    class Endpoint
      
      def initialize(&block)
        @block = block
      end

      def call(env)
        request = Rack::Request.new env
        body = request.body.gets
        request.params.merge! JSON.parse(body) if body
        request.params.merge! env[PATH_PARAMS]
        response = Rack::Response.new
        @block.call request, response, Render.new(request, response)
        response.finish
      end

    end
  end
end