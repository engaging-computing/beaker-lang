require 'test_helper'

class BeakerTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Beaker::VERSION
  end
end
