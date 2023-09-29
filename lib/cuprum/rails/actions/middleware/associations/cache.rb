# frozen_string_literal: true

require 'cuprum/rails/actions/middleware/associations'

module Cuprum::Rails::Actions::Middleware::Associations
  # Pre-warm the association cache for a resource.
  class Cache < Cuprum::Command
    # Strategy for caching an association value on an ActiveRecord model.
    ACTIVE_RECORD_STRATEGY = lambda do |entity:, name:, value:|
      entity.send(:association_instance_set, name, value)

      entity
    end

    # Generic strategy for caching an association value.
    DEFAULT_STRATEGY = lambda do |entity:, name:, value:|
      entity[name] = value

      entity
    end

    STRATEGIES = {
      Object             => DEFAULT_STRATEGY,
      ActiveRecord::Base => ACTIVE_RECORD_STRATEGY
    }.freeze
    private_constant :STRATEGIES

    class << self
      # Defines a strategy for caching an association value.
      #
      # @param klass [Class] the base class or module for matching entities.
      #
      # @yield the strategy for caching the association value.
      #
      # @yieldparam entity [Object] the base entity.
      # @yieldparam name [String] the name of the association.
      # @yieldparam value [Object] the associated entity to cache.
      #
      # @yieldreturn [Object] the entity with cached assocation value.
      def define_strategy(klass, &block)
        (@strategies ||= STRATEGIES.dup)[klass] = block
      end

      # @return [Proc] the defined strategies for caching association values.
      def strategies
        (@strategies ||= STRATEGIES.dup).reverse_each
      end
    end

    # @param association [Cuprum::Associations::Association] the association
    #   to cache.
    # @param resource [Cuprum::Rails::Resource] the resource to cache.
    def initialize(association:, resource:)
      super()

      @association = association
      @resource    = resource
    end

    # @return [Cuprum::Associations::Association] the association to cache.
    attr_reader :association

    # @return [Cuprum::Rails::Resource] the resource to cache.
    attr_reader :resource

    private

    def cache_association(entity:, value:)
      value    = value.first if association.singular?
      strategy =
        self.class.strategies.find { |klass, _| entity.is_a?(klass) }.last

      strategy.call(
        entity: entity,
        name:   association.name,
        value:  value
      )
    end

    def convert_to_array(value)
      return [] if value.nil?

      return value if value.is_a?(Array)

      [value]
    end

    def index_values(values:)
      key_name = association.with_inverse(resource).query_key_name

      values
        .each
        .with_object(Hash.new { |hsh, key| hsh[key] = [] }) do |value, hsh|
          hsh[value[key_name]] << value

          hsh
        end
    end

    def process(entities:, values:)
      indexed = index_values(values: convert_to_array(values))
      cached  = convert_to_array(entities).map do |entity|
        cache_association(
          entity: entity,
          value:  indexed[entity[association.inverse_key_name]]
        )
      end

      entities.is_a?(Array) ? cached : cached.first
    end
  end
end
