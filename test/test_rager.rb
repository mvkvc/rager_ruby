# typed: false
# frozen_string_literal: true

require "test_helper"

class TestRager < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Rager::VERSION
  end
end
