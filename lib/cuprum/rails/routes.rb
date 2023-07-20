# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Represent the routes available for a given resource.
  class Routes
    # Error class when a wildcard value is missing for a route.
    class MissingWildcardError < StandardError; end

    class << self
      # Defines a route for the resource routes.
      #
      # Each defined route creates a helper method on the routes, which returns
      # the full path of the resource route. A member action helper (if the
      # path ends in an :id wildcard) will require passing in either the primary
      # key of the member or the member entity.
      #
      # If the base path includes wildcards, then the wildcards must be set
      # (using #with_wildcards) before calling a route helper.
      #
      # @param action_name [String, Symbol] The name of the action.
      # @param path [String] The path of the action relative to the resource
      #   root. If the path has a leading slash, the path is treated as an
      #   absolute path and does not include the routes base path.
      def route(action_name, path)
        validate_action_name!(action_name)
        validate_path!(path)

        if member_route?(path)
          define_member_route(action_name, path)
        else
          define_collection_route(action_name, path)
        end
      end

      private

      def define_collection_route(action_name, original_path)
        define_method :"#{action_name}_path" do
          path = resolve_base_path(original_path)

          insert_wildcards(path)
        end
      end

      def define_member_route(action_name, original_path)
        define_method :"#{action_name}_path" do |entity|
          path = resolve_base_path(original_path)

          insert_wildcards(path, entity)
        end
      end

      def member_route?(path)
        path.split('/').include?(':id')
      end

      def validate_action_name!(action_name)
        unless action_name.is_a?(String) || action_name.is_a?(Symbol)
          raise ArgumentError,
            'action_name must be a String or Symbol',
            caller(1..-1)
        end

        return unless action_name.to_s.empty?

        raise ArgumentError, "action_name can't be blank", caller(1..-1)
      end

      def validate_path!(path)
        return if path.is_a?(String) || path.is_a?(Symbol)

        raise ArgumentError, 'path must be a String or Symbol', caller(1..-1)
      end
    end

    # @param base_path [String] The relative path of the resource.
    def initialize(base_path:, &block)
      @base_path = base_path
      @wildcards = {}

      singleton_class.instance_exec(&block) if block_given?
    end

    # @return [String] the relative path of the resource.
    attr_reader :base_path

    # @return [String] the url wildcards for the resource.
    attr_reader :wildcards

    # @return [String] the path to the parent resource index.
    def parent_path
      root_path
    end

    # @return [String] the root path for the application.
    def root_path
      '/'
    end

    # @param wildcards [Hash] The wildcards to use with the routes.
    #
    # @return [Cuprum::Rails::Routes] a copy of the routes with the wildcards.
    def with_wildcards(wildcards)
      unless wildcards.is_a?(Hash)
        raise ArgumentError, 'wildcards must be a Hash'
      end

      clone.apply_wildcards(wildcards)
    end

    protected

    def apply_wildcards(wildcards)
      @wildcards = wildcards.stringify_keys

      self
    end

    private

    def insert_wildcards(path, value_or_entity = nil)
      path
        .split('/')
        .map do |segment|
          next segment unless segment.start_with?(':')

          next resolve_primary_key(value_or_entity) if segment == ':id'

          resolve_wildcard(segment)
        end
        .join('/')
    end

    def resolve_base_path(path)
      return path if path.start_with?('/')

      return base_path if path.empty?

      "#{base_path}/#{path}"
    end

    def resolve_primary_key(value_or_entity)
      raise MissingWildcardError, 'missing wildcard :id' if value_or_entity.nil?

      unless value_or_entity.class.respond_to?(:primary_key)
        return value_or_entity
      end

      primary_key = value_or_entity.class.primary_key

      value_or_entity[primary_key]
    end

    def resolve_wildcard(segment)
      wildcard = segment[1..] # :something_id to something_id

      return wildcards[wildcard] if wildcards.include?(wildcard)

      wildcard = segment[1...-3] # :something_id to something

      if wildcards.include?(wildcard)
        return resolve_primary_key(wildcards[wildcard])
      end

      raise MissingWildcardError, "missing wildcard #{segment}"
    end
  end
end
