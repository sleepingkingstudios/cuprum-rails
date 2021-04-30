# frozen_string_literal: true

module Spec
  module ContractHelpers
    # :nocov:
    def finclude_contract(contract, *args, **kwargs)
      fdescribe '(focused)' do # rubocop:disable RSpec/EmptyExampleGroup, RSpec/Focus
        if kwargs.empty?
          include_contract(contract, *args)
        else
          include_contract(contract, *args, **kwargs)
        end
      end
    end

    def include_contract(contract, *args, **kwargs)
      if kwargs.empty?
        instance_exec(*args, &contract)
      else
        instance_exec(*args, **kwargs, &contract)
      end
    end

    def xinclude_contract(contract, *args, **kwargs)
      xdescribe '(skipped)' do # rubocop:disable RSpec/EmptyExampleGroup
        if kwargs.empty?
          include_contract(contract, *args)
        else
          include_contract(contract, *args, **kwargs)
        end
      end
    end
    # :nocov:
  end
end
