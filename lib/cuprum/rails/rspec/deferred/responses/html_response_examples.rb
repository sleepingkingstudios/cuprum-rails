# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/rails/rspec/deferred/responses'

module Cuprum::Rails::RSpec::Deferred::Responses
  # Deferred examples for validating HTML responses.
  module HtmlResponseExamples
    include RSpec::SleepingKingStudios::Deferred::Provider

    # Asserts that the response redirects back with the specified fallback.
    #
    # @param fallback_location [String] the fallback location for the redirect.
    #   Defaults to '/'.
    # @param flash [Hash] the flash messages set for the redirect. Defaults to
    #   an empty Hash.
    # @param status [Integer] the HTTP status for the redirect. Defaults to 302
    #   Found.
    #
    # The following methods must be defined in the example group:
    #
    # - #response: The response being tested.
    deferred_examples 'should redirect back' \
    do |fallback_location: '/', flash: {}, status: 302|
      include RSpec::SleepingKingStudios::Deferred::Dependencies

      depends_on :response, 'the response being tested'

      let(:response) do
        next super() if defined?(super())

        # :nocov:

        # @deprecate 0.3.0 Calling response examples without an explicit
        #   #response object.
        SleepingKingStudios::Tools::Toolbelt.instance.core_tools.deprecate(
          'HtmlResponseExamples "should redirect back"',
          'Please provide an explicit #response object.'
        )

        subject.call(result)
        # :nocov:
      end
      let(:configured_fallback) do
        next fallback_location unless fallback_location.is_a?(Proc)

        instance_exec(&fallback_location)
      end
      let(:configured_flash) do
        next flash unless flash.is_a?(Proc)

        # :nocov:
        instance_exec(&flash)
        # :nocov:
      end

      it 'should redirect to the previous path' do
        expect(response)
          .to be_a Cuprum::Rails::Responses::Html::RedirectBackResponse
      end

      it { expect(response.fallback_location).to match(configured_fallback) }

      it { expect(response.flash).to match(configured_flash) }

      it { expect(response.status).to match(status) }
    end

    # Asserts that the response redirects to the given path.
    #
    # @param path [String] the path for the redirect.
    # @param flash [Hash] the flash messages set for the redirect. Defaults to
    #   an empty Hash.
    # @param status [Integer] the HTTP status for the redirect. Defaults to 302
    #   Found.
    #
    # The following methods must be defined in the example group:
    #
    # - #response: The response being tested.
    deferred_examples 'should redirect to' do |path, flash: {}, status: 302|
      include RSpec::SleepingKingStudios::Deferred::Dependencies

      depends_on :response, 'the response being tested'

      let(:response) do
        next super() if defined?(super())

        # :nocov:

        # @deprecate 0.3.0 Calling response examples without an explicit
        #   #response object.
        SleepingKingStudios::Tools::Toolbelt.instance.core_tools.deprecate(
          'HtmlResponseExamples "should redirect back"',
          'Please provide an explicit #response object.'
        )

        subject.call(result)
        # :nocov:
      end
      let(:configured_path) do
        next path unless path.is_a?(Proc)

        instance_exec(&path)
      end
      let(:configured_flash) do
        next flash unless flash.is_a?(Proc)

        # :nocov:
        instance_exec(&flash)
        # :nocov:
      end

      it 'should redirect to the specified path' do
        expect(response)
          .to be_a Cuprum::Rails::Responses::Html::RedirectResponse
      end

      it { expect(response.flash).to match(configured_flash) }

      it { expect(response.path).to match(configured_path) }

      it { expect(response.status).to match(status) }
    end

    # Asserts that the response renders the given view template.
    #
    # @param template [String] the template to render.
    # @param assigns [Hash] the expected values assigned to the template.
    #   Defaults to an empty Hash.
    # @param flash [Hash] the flash messages set for the rendered view. Defaults
    #   to an empty Hash.
    # @param layout [String] the layout to render, if any.
    # @param status [Integer] the HTTP status for the rendered view. Defaults to
    #   200 OK.
    #
    # The following methods must be defined in the example group:
    #
    # - #response: The response being tested.
    deferred_examples 'should render template' \
    do |template, assigns: {}, flash: {}, layout: nil, status: 200|
      include RSpec::SleepingKingStudios::Deferred::Dependencies

      depends_on :response, 'the response being tested'

      let(:response) do
        next super() if defined?(super())

        # :nocov:

        # @deprecate 0.3.0 Calling response examples without an explicit
        #   #response object.
        SleepingKingStudios::Tools::Toolbelt.instance.core_tools.deprecate(
          'HtmlResponseExamples "should redirect back"',
          'Please provide an explicit #response object.'
        )

        subject.call(result)
        # :nocov:
      end
      let(:configured_assigns) do
        next assigns unless assigns.is_a?(Proc)

        instance_exec(&assigns)
      end
      let(:configured_flash) do
        next flash unless flash.is_a?(Proc)

        # :nocov:
        instance_exec(&flash)
        # :nocov:
      end
      let(:configured_layout) do
        next layout unless layout.is_a?(Proc)

        # :nocov:
        instance_exec(&layout)
        # :nocov:
      end
      let(:configured_template) do
        next template unless template.is_a?(Proc)

        instance_exec(&template)
      end

      it 'should render a view' do
        expect(response)
          .to be_a Cuprum::Rails::Responses::Html::RenderResponse
      end

      it { expect(response.template).to match(configured_template) }

      it { expect(response.assigns).to match(configured_assigns) }

      it { expect(response.flash).to match(configured_flash) }

      it { expect(response.layout).to match(configured_layout) }

      it { expect(response.status).to match(status) }
    end
  end
end
