# frozen_string_literal: true

require 'support/commands'

module Spec::Support::Commands
  module Monsters
    FIXTURES = [
      {
        'id'        => 0,
        'name'      => 'Skeleton',
        'challenge' => '1/2',
        'type'      => 'bones'
      },
      {
        'id'        => 1,
        'name'      => 'Ghoul',
        'challenge' => '1',
        'type'      => 'flesh'
      },
      {
        'id'        => 2,
        'name'      => 'Ghost',
        'challenge' => '2',
        'type'      => 'ectoplasm'
      },
      {
        'id'        => 3,
        'name'      => 'Ghast',
        'challenge' => '3',
        'type'      => 'flesh'
      },
      {
        'id'        => 4,
        'name'      => 'Mummy',
        'challenge' => '5',
        'type'      => 'flesh'
      },
      {
        'id'        => 5,
        'name'      => 'Vampire',
        'challenge' => '10',
        'type'      => 'flesh'
      },
      {
        'id'        => 6,
        'name'      => 'Lich',
        'challenge' => '20',
        'type'      => 'bones'
      }
    ].map(&:freeze).freeze
  end
end
