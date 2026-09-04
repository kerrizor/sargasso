# frozen_string_literal: true

require "test_helper"
require "stringio"
require "sargasso/cli"

class TestCLI < Minitest::Test
  FIXTURE_DIR = File.expand_path("fixtures", __dir__)

  def test_converts_a_file_to_stdout
    out = StringIO.new
    status = run_cli([File.join(FIXTURE_DIR, "basic_sequence.puml")], stdout: out)

    assert_equal 0, status
    assert_includes out.string, "Alice->>Bob: Hello"
  end

  def test_reads_from_stdin_with_dash
    stdin = StringIO.new(File.read(File.join(FIXTURE_DIR, "basic_sequence.puml")))
    out = StringIO.new
    status = run_cli(["-"], stdin: stdin, stdout: out)

    assert_equal 0, status
    assert_includes out.string, "sequenceDiagram"
  end

  def test_strict_mode_exits_non_zero_on_unsupported
    stdin = StringIO.new("@startuml\nskinparam x y\n@enduml\n")
    status = run_cli(["--strict", "-"], stdin: stdin, stdout: StringIO.new, stderr: StringIO.new)

    assert_equal 1, status
  end

  def test_missing_file_exits_non_zero
    status = run_cli(["nope.puml"], stdout: StringIO.new, stderr: StringIO.new)

    assert_equal 1, status
  end

  private

  def run_cli(argv, stdin: StringIO.new, stdout: StringIO.new, stderr: StringIO.new)
    Sargasso::CLI.new(argv, stdin: stdin, stdout: stdout, stderr: stderr).run
  end
end
