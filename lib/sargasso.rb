# frozen_string_literal: true

require_relative "sargasso/version"
require_relative "sargasso/ast"
require_relative "sargasso/parser"
require_relative "sargasso/emitters/mermaid"

# Sargasso converts PlantUML diagram source into equivalent Mermaid source.
#
# v1 supports sequence diagrams only. The pipeline is:
#   PlantUML source -> Sargasso::Parser -> Sargasso::AST -> Emitters::Mermaid
#
module Sargasso
  class Error < StandardError; end

  # Raised when strict mode encounters a construct sargasso cannot convert.
  #
  class UnsupportedConstructError < Error; end

  module_function

  # Convert PlantUML source into Mermaid source.
  #
  # strict: raise UnsupportedConstructError on any unsupported construct.
  # warnings: an optional array that collected warnings are appended to.
  #
  def convert(plantuml_string, strict: false, warnings: nil)
    diagram = Parser.new(plantuml_string).parse
    emitter = Emitters::Mermaid.new(strict: strict)
    output = emitter.emit(diagram)
    warnings&.concat(emitter.warnings)
    output
  end
end
