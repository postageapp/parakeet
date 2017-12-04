require_relative '../test_helper'

class ParakeetTest < Test::Unit::TestCase
  def test_symbolize_keys_on_miscellaneous
    assert_mapping(
      true => true,
      false => false,
      nil => nil,
      [ ] => [ ],
      { } => { },
      1 => 1,
      0 => 0,
      'one' => 'one'
    ) do |v|
      Parakeet::Support.symbolize_keys(v)
    end
  end

  def test_symbolize_keys_on_hash
    input = {
      'test' => 'value',
      'nested' => {
        'value' => true
      },
      'array' => [
        'simple',
        {
          'nested' => 'hash'
        }
      ]
    }

    output = {
      test: 'value',
      nested: {
        value: true
      },
      array: [
        'simple',
        {
          nested: 'hash'
        }
      ]
    }

    assert_equal output, Parakeet::Support.symbolize_keys(input)
  end
end
