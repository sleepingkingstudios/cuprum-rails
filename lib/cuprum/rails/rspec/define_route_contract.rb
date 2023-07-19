# frozen_string_literal: true

require 'cuprum/rails/rspec'

module Cuprum::Rails::RSpec
  # Contract asserting that a Routes object defines the given route.
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
        describe 'when the value or entity is nil' do
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

        describe 'when the value or entity is an Integer' do
          let(:value)    { 12_345 }
          let(:expected) { path.sub(':id', value.to_s) }
          let(:scoped_routes) do
            wildcards.empty? ? routes : routes.with_wildcards(wildcards)
          end

          it 'should apply the value to the path' do
            expect(scoped_routes.send(method_name, value)).to be == expected
          end
        end

        describe 'when the value or entity is a String' do
          let(:value)    { '12345' }
          let(:expected) { path.sub(':id', value) }
          let(:scoped_routes) do
            wildcards.empty? ? routes : routes.with_wildcards(wildcards)
          end

          it 'should apply the value to the path' do
            expect(scoped_routes.send(method_name, value)).to be == expected
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
