module Rasti
  module Web
    class Controller
      
      extend Forwardable

      def_delegators :request, :params, :session
      def_delegator :response, :redirect, :redirect_to

      attr_reader :request, :response, :render

      def initialize(request, response, render)
        @request = request
        @response = response
        @render = render
      end

      class << self
        def action(action_name)
          raise "Undefined action '#{action_name}' in #{name}" unless instance_methods.include? action_name.to_sym
          
          Endpoint.new do |req, res, render|
            controller = new req, res, render
            begin
              controller.public_send action_name
            rescue => ex
              if controller.respond_to? ex.class.name
                controller.public_send ex.class.name, ex
              else
                raise ex
              end
            end
          end
        end

        alias_method :>>, :action

        def rescue_from(exception_class, &block)
          define_method exception_class.name do |ex|
            instance_exec ex, &block
          end
        end
      end

    end
  end
end