require_relative '../test_helper'

class ParakeetConfigTest < Test::Unit::TestCase
  def test_defaults
    config = Parakeet::Config.new(example_path('empty.yml'))

    assert config

    assert config.instances
    assert_equal 0, config.instances.keys.length
  end

  def test_defaults_missing_path
    config = Parakeet::Config.new(example_path('doesnotexist.yml'))

    assert config
    
    assert config.instances
    assert_equal 0, config.instances.keys.length
  end
end
