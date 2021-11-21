# frozen_string_literal: true

require 'cuprum/rails/controllers/class_methods'
require 'cuprum/rails/controllers/middleware'

module Cuprum::Rails::Controllers::ClassMethods
  # Provides a DSL for defining controller middleware.
  module Middleware
    def middleware(command = nil, except: [], only: [])
      unless command.nil?
        own_middleware <<
          build_middleware(command: command, except: except, only: only)
      end

      ancestors
        .select { |ancestor| ancestor.respond_to?(:own_middleware) }
        .reverse_each
        .map(&:own_middleware)
        .reduce(&:+)
    end

    # @private
    def own_middleware
      @own_middleware ||= []
    end

    private

    def build_middleware(command:, except:, only:)
      validate_command!(command)
      validate_action_names!(except, as: 'except')
      validate_action_names!(only,   as: 'only')

      Cuprum::Rails::Controllers::Middleware.new(
        command: command.is_a?(Class) ? command.new : command,
        except:  except,
        only:    only
      )
    end

    def valid_action_names?(action_names)
      return false unless action_names.is_a?(Array)

      action_names.all? do |action_name|
        next false unless action_name.is_a?(String) || action_name.is_a?(Symbol)

        !action_name.empty?
      end
    end

    def validate_action_names!(action_names, as:) # rubocop:disable Naming/MethodParameterName
      return if action_names.nil?

      return if valid_action_names?(action_names)

      raise ArgumentError,
        "#{as} must be a list of action names",
        caller(1..-1)
    end

    def validate_command!(command)
      return if command.is_a?(Cuprum::Command)

      return if command.is_a?(Class) && command < Cuprum::Command

      raise ArgumentError,
        'command must be an instance of or subclass of Cuprum::Command',
        caller(1..-1)
    end
  end
end
