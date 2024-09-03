# frozen_string_literal: true

require 'cuprum/rails'

module Cuprum::Rails
  # Result class representing the result of calling an action.
  #
  # In addition to the standard properties inherited from Cuprum::Result, each
  # Cuprum::Rails::Result also includes a #metadata property. This represents
  # secondary information about the result that may be relevant for rendering or
  # displaying the data, but is not part of the requested value. For example.
  # information about the current controller would be metadata, as would the
  # current authentication session.
  class Result < Cuprum::Result
    # @param value [Object] the value returned by calling the action.
    # @param error [Cuprum::Error] the error (if any) generated when the action
    #   was called.
    # @param metadata [Hash{Symbol => Object}] the request or action metadata.
    # @param status [String, Symbol, nil] the status of the result. Must be
    #   :success, :failure, or nil.
    def initialize(error: nil, metadata: {}, status: nil, value: nil)
      super(error: error, status: status, value: value)

      @metadata = metadata
    end

    # @return [Hash{Symbol => Object}] the request or action metadata.
    attr_reader :metadata

    # @return [Hash{Symbol => Object}] a Hash representation of the result.
    def properties
      super.merge(metadata: metadata)
    end
    alias to_h properties
  end
end
