# frozen_string_literal: true

require 'cuprum/rails/controllers/action'
require 'cuprum/rails/controllers/class_methods'

module Cuprum::Rails::Controllers::ClassMethods
  # Provides a DSL for defining controller actions.
  module Actions
    # @overload action(action_name, action_class, **options)
    #   Defines a controller action with the given action class.
    #
    #   @param action_name [String, Symbol] the name of the action.
    #   @param action_class [Class] the class of the action command.
    #   @param options [Hash] additional options for the action.
    #
    #   @option options command_class [Class] sets the command class wrapped by
    #     the action. Defaults to nil.
    #   @option options member [Boolean] true if the action acts on a collection
    #     item, not on the collection as a whole. Defaults to false.
    #
    # @overload action(action_name, member: false, &implementation)
    #   Defines a controller action with the given implementation.
    #
    #   @param action_name [String, Symbol] the name of the action.
    #   @param options [Hash] additional options for the action.
    #
    #   @option options member [Boolean] true if the action acts on a collection
    #     item, not on the collection as a whole. Defaults to false.
    #
    #   @yield the action implementation.
    #   @yieldparam request [ActionDispatch::Request] the Rails request.
    #   @yieldparam repository [Cuprum::Collections::Repository] the repository
    #     containing the data collections for the application or scope.
    #   @yieldparam options [Hash<Symbol, Object>] additional options for the
    #     action.
    #   @yieldreturn [Cuprum::Result] the result of the action.
    def action(action_name, action_class = nil, **options, &) # rubocop:disable Metrics/MethodLength
      validate_name(action_name, as: 'action name')

      options = apply_default_options(action_name, **options)

      action_class = resolve_action_class(action_class, &)
      action_class = apply_subclass_options(action_class, **options)
      action_name  = action_name.intern

      own_actions[action_name] = Cuprum::Rails::Controllers::Action.new(
        action_class:,
        action_name:,
        member_action: options[:member]
      )

      define_action(action_name)
    end

    # @return [Hash<Symbol, Cuprum::Rails::Controllers::Action>] the actions
    #   defined for the controller.
    def actions
      ancestors
        .select { |ancestor| ancestor.respond_to?(:own_actions) }
        .reverse_each
        .map(&:own_actions)
        .reduce(&:merge)
    end

    # @private
    def apply_request_defaults(request)
      request.format ||= configuration.default_format
    end

    # Generates a Cuprum::Rails::Request from a native request.
    #
    # Override this method to generate a request subclass.
    #
    # @param context [#request] the controller or controller context.
    # @param options [Hash{Symbol=>Object}] additional options for the request.
    #
    # @return [Cuprum::Rails::Request] the generated request.
    def build_request(context, **options)
      Cuprum::Rails::Request.build(
        context:,
        request: context.request,
        **options
      )
    end

    # @private
    def own_actions
      # :nocov:
      @own_actions ||= {}
      # :nocov:
    end

    private

    def apply_default_options(_action_name, **options)
      options[:member] = false if options[:member].nil?

      options
    end

    def apply_subclass_options(action_class, **options)
      subclass_options = options.slice(:command_class).compact

      return action_class if subclass_options.empty?

      action_class.subclass(**subclass_options)
    end

    def define_action(action_name) # rubocop:disable Metrics/MethodLength
      define_method(action_name) do
        action  = self.class.actions[action_name]
        request =
          self
            .class
            .build_request(self, member_action: action.member_action?)
            .tap { |req| self.class.apply_request_defaults(req) }

        response = action.call(self, request)
        response.call(self)
        response
      end
    end

    def resolve_action_class(action_class, &)
      if block_given? && action_class
        raise ArgumentError, 'unexpected block when action class is given'
      elsif block_given?
        Cuprum::Rails::Action.subclass(&)
      else
        validate_class(action_class, as: 'action class')

        action_class
      end
    end
  end
end
