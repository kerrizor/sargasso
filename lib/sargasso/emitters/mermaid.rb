# frozen_string_literal: true

require_relative "../ast"

module Sargasso
  module Emitters
    # Emits Mermaid sequenceDiagram source from a Sargasso::AST::Diagram.
    #
    # Each message line is indented one level (4 spaces) under the
    # "sequenceDiagram" header. Nested groups (alt/else) add further indentation.
    #
    class Mermaid
      ARROWS = { solid: "->>", dashed: "-->>" }.freeze
      INDENT = "    "

      # warnings collects human-readable messages about unsupported constructs.
      # In strict mode the first unsupported construct raises instead.
      #
      attr_reader :warnings

      def initialize(strict: false)
        @strict = strict
        @warnings = []
      end

      def emit(diagram)
        lines = ["sequenceDiagram"]
        emit_nodes(diagram.nodes, lines, 1)
        "#{lines.join("\n")}\n"
      end

      private

      def emit_nodes(nodes, lines, depth)
        nodes.each { |node| emit_node(node, lines, depth) }
      end

      def emit_node(node, lines, depth)
        case node
        when AST::Participant then lines << participant_line(node, depth)
        when AST::Message then lines << message_line(node, depth)
        when AST::Alt then emit_alt(node, lines, depth)
        when AST::Unsupported then handle_unsupported(node)
        end
      end

      def participant_line(node, depth)
        line = "#{INDENT * depth}participant #{node.id}"
        line += " as #{node.label}" if node.label
        line
      end

      def message_line(node, depth)
        "#{INDENT * depth}#{node.from}#{ARROWS.fetch(node.arrow)}#{node.to}: #{node.text}"
      end

      def emit_alt(alt, lines, depth)
        alt.branches.each_with_index do |branch, index|
          keyword = index.zero? ? "alt" : "else"
          label = branch.label.empty? ? keyword : "#{keyword} #{branch.label}"
          lines << "#{INDENT * depth}#{label}"
          emit_nodes(branch.nodes, lines, depth + 1)
        end
        lines << "#{INDENT * depth}end"
      end

      def handle_unsupported(node)
        message = "unsupported construct: #{node.source.inspect}"
        raise Sargasso::UnsupportedConstructError, message if @strict

        @warnings << message
      end
    end
  end
end
