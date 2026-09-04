# frozen_string_literal: true

require "test_helper"

class TestSargasso < Minitest::Test
  include FixtureHelper

  def test_that_it_has_a_version_number
    refute_nil ::Sargasso::VERSION
  end

  def test_basic_sequence
    assert_fixture_converts("basic_sequence")
  end

  def test_participant_aliases
    assert_fixture_converts("participant_aliases")
  end

  def test_dashed_return
    assert_fixture_converts("dashed_return")
  end

  def test_alt_else
    assert_fixture_converts("alt_else")
  end

  def test_strict_mode_raises_on_unsupported_construct
    assert_raises(Sargasso::UnsupportedConstructError) do
      Sargasso.convert("@startuml\nskinparam monochrome true\n@enduml", strict: true)
    end
  end

  def test_non_strict_collects_warnings
    warnings = []
    Sargasso.convert("@startuml\nskinparam monochrome true\n@enduml", warnings: warnings)

    refute_empty warnings
  end
end
