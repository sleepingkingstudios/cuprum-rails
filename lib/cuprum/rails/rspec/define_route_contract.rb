# frozen_string_literal: true

require 'cuprum/rails/rspec'

module Cuprum::Rails::RSpec
  DEFINE_ROUTE_CONTRACT = lambda \
  do |action_name:, path:, member_action: false, wildcards: {}|
    describe "##{action_name}_path" do
      let(:method_name) { "#{action_name}_path" }
      let(:expected) do
        next path unless member_action

        primary_key_name  = entity.class.primary_key
        primary_key_value = entity[primary_key_name]

        path.sub(':id', primary_key_value.to_s)
      end

      define_method(:route_helper) do
        scoped = wildcards.empty? ? routes : routes.with_wildcards(wildcards)

        if member_action
          scoped.send(method_name, entity)
        else
          scoped.send(method_name)
        end
      end

      it 'should define the helper method' do
        if member_action
          expect(routes).to respond_to(method_name).with(1).argument
        else
          expect(routes).to respond_to(method_name).with(0).arguments
        end
      end

      it 'should return the route path' do
        expect(route_helper).to be == expected
      end

      if member_action
        describe 'when the entity is nil' do
          let(:entity)        { nil }
          let(:error_message) { 'missing wildcard :id' }

          it 'should raise an exception' do
            expect { route_helper }
              .to raise_error(
                described_class::MissingWildcardError,
                error_message
              )
          end
        end
      end

      wildcards.each do |key, _|
        wildcard = key.to_s.end_with?('_id') ? key.intern : :"#{key}_id"

        describe "when the #{wildcard.inspect} wildcard is undefined" do
          let(:error_message) { "missing wildcard #{wildcard.inspect}" }

          define_method(:route_helper) do
            scoped = routes.with_wildcards(wildcards.except(key))

            if member_action
              scoped.send(method_name, entity)
            else
              scoped.send(method_name)
            end
          end

          it 'should raise an exception' do
            expect { route_helper }
              .to raise_error(
                described_class::MissingWildcardError,
                error_message
              )
          end
        end
      end
    end
  end
end
