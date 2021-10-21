# frozen_string_literal: true

module Spec
  module ContractHelpers
    # :nocov:
    # rubocop:disable RSpec/Focus
    def finclude_contract(contract, *args, **kwargs)
      fdescribe '(focused)' do
        if kwargs.empty?
          include_contract(contract, *args)
        else
          include_contract(contract, *args, **kwargs)
        end
      end
    end
    # rubocop:enable RSpec/Focus

    def include_contract(contract, *args, **kwargs)
      if kwargs.empty?
        instance_exec(*args, &contract)
      else
        instance_exec(*args, **kwargs, &contract)
      end
    end

    def xinclude_contract(contract, *args, **kwargs)
      xdescribe '(skipped)' do
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
