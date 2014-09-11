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

      def session
        request.session
      end

      def self.action(action_name)
        raise "Undefined action #{action_name} in #{name}" unless instance_methods.include? action_name.to_sym
        
        Endpoint.new do |req, res|
          self.new(req, res).public_send(action_name)
        end
      end

      def self.>>(action_name)
        action action_name
      end

    end
  end
end