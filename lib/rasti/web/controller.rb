module Rasti
  module Web
    class Controller
      
      attr_reader :request, :response, :render, :params

      def initialize(request, response)
        @request = request
        @response = response
        @render = Render.new response
        @params = Parameters.new request.params
      end

      def self.action(name)
        Endpoint.new do |req, res|
          self.new(req, res).public_send(name)
        end
      end

    end
  end
end