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
              call_before_action controller, action_name
              controller.public_send action_name
            rescue => ex
              call_exception_handler controller, ex
            ensure
              call_after_action controller, action_name
            end
          end
        end

        alias_method :>>, :action

        def before_action(action_name=nil, &block)
          before_action_hooks[action_name] = block
        end

        def after_action(action_name=nil, &block)
          after_action_hooks[action_name] = block
        end

        def rescue_from(exception_class, &block)
          exception_handlers[exception_class] = block
        end

        def call_before_action(controller, action_name)
          hook = before_action_hooks[action_name] || before_action_hooks[nil]
          controller.instance_exec action_name, &hook if hook
        end

        def call_after_action(controller, action_name)
          hook = after_action_hooks[action_name] || after_action_hooks[nil]
          controller.instance_exec action_name, &hook if hook
        end

        def call_exception_handler(controller, exception)
          exception_class = handled_exceptions.detect { |klass| exception.is_a? klass }
          exception_handler = exception_handlers[exception_class]
          if exception_handler
            controller.instance_exec exception, &exception_handler
          else
            raise exception
          end
        end

        def before_action_hooks
          @before_action_hooks ||= superclass.respond_to?(:before_action_hooks) ? superclass.before_action_hooks.dup : {}
        end

        def after_action_hooks
          @after_action_hooks ||= superclass.respond_to?(:after_action_hooks) ? superclass.after_action_hooks.dup : {}
        end

        def exception_handlers
          @exception_handlers ||= superclass.respond_to?(:exception_handlers) ? superclass.exception_handlers.dup : {}
        end

        def handled_exceptions
          @handled_exceptions ||= ClassAncestrySort.desc exception_handlers.keys
        end

      end

    end
  end
end