# frozen_string_literal: true

require "optparse"
require_relative "../sargasso"

module Sargasso
  # Command-line entry point.
  #
  #   sargasso path/to/diagram.puml     # -> stdout Mermaid
  #   cat diagram.puml | sargasso -     # stdin -> stdout
  #   sargasso --quiet ...              # suppress warnings
  #   sargasso --strict ...             # fail on any unsupported construct
  #
  class CLI
    def initialize(argv, stdin: $stdin, stdout: $stdout, stderr: $stderr)
      @argv = argv
      @stdin = stdin
      @stdout = stdout
      @stderr = stderr
      @options = { quiet: false, strict: false }
    end

    # Returns a process exit status (0 success, non-zero failure).
    #
    def run
      paths = parse_options
      return 0 if @help

      source = read_source(paths)
      return 1 if source.nil?

      convert_and_emit(source)
    rescue Sargasso::UnsupportedConstructError => e
      @stderr.puts("sargasso: #{e.message}")
      1
    end

    private

    def convert_and_emit(source)
      warnings = []
      output = Sargasso.convert(source, strict: @options[:strict], warnings: warnings)
      @stdout.puts(output)
      report_warnings(warnings)
      0
    end

    def parse_options
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: sargasso [options] FILE|-"
        opts.on("--quiet", "Suppress warnings") { @options[:quiet] = true }
        opts.on("--strict", "Fail on any unsupported construct") { @options[:strict] = true }
        opts.on("-h", "--help", "Show this help") do
          @stdout.puts(opts)
          @help = true
        end
      end
      parser.parse(@argv)
    end

    def read_source(paths)
      path = paths.first
      if path.nil?
        @stderr.puts("sargasso: no input file given (use '-' for stdin)")
        return nil
      end

      path == "-" ? @stdin.read : File.read(path)
    rescue Errno::ENOENT
      @stderr.puts("sargasso: no such file: #{path}")
      nil
    end

    def report_warnings(warnings)
      return if @options[:quiet]

      warnings.each { |w| @stderr.puts("sargasso: warning: #{w}") }
    end
  end
end
