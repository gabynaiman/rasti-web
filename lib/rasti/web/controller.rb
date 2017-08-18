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
              exception_class = handled_exceptions.detect { |klass| ex.is_a? klass }
              if exception_class
                controller.instance_exec ex, &exception_handlers[exception_class]
              else
                raise ex
              end
            end
          end
        end

        alias_method :>>, :action

        def exception_handlers
          @exception_handlers ||= superclass.respond_to?(:exception_handlers) ? superclass.exception_handlers : {}
        end

        def handled_exceptions
          @handled_exceptions ||= ClassAncestrySort.desc exception_handlers.keys
        end

        def rescue_from(exception_class, &block)
          exception_handlers[exception_class] = block
        end
      end

    end
  end
end