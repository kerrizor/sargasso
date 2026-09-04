# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "sargasso"

require "minitest/autorun"

module FixtureHelper
  FIXTURE_DIR = File.expand_path("fixtures", __dir__)

  # Assert that converting <name>.puml produces exactly <name>.mmd.
  #
  def assert_fixture_converts(name)
    puml = File.read(File.join(FIXTURE_DIR, "#{name}.puml"))
    mmd = File.read(File.join(FIXTURE_DIR, "#{name}.mmd"))

    assert_equal mmd, Sargasso.convert(puml), "fixture #{name} did not convert as expected"
  end
end
