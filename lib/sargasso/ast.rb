# frozen_string_literal: true

module Sargasso
  # Diagram-agnostic AST nodes.
  #
  # These structs describe the semantic content of a diagram independent of any
  # source (PlantUML) or target (Mermaid) syntax. Parsers build them; emitters
  # consume them. Keeping this layer neutral is what lets a future grammar or a
  # future emitter (draw.io, graphviz) slot in without a rewrite.
  #
  module AST
    # The root of a parsed diagram. For v1, kind is always :sequence.
    #
    Diagram = Struct.new(:kind, :nodes, keyword_init: true) do
      def initialize(kind:, nodes: [])
        super
      end
    end

    # A declared participant or actor, with an optional display label.
    #
    # id is the identifier used in messages. label is the human display name
    # (nil when the declaration had no alias).
    #
    Participant = Struct.new(:id, :label, keyword_init: true)

    # A message from one participant to another.
    #
    # arrow is the neutral arrow kind: :solid or :dashed. The emitter decides
    # the concrete target syntax.
    #
    Message = Struct.new(:from, :to, :text, :arrow, keyword_init: true)

    # An alt/else group. branches is an array of Branch nodes.
    #
    Alt = Struct.new(:branches, keyword_init: true) do
      def initialize(branches: [])
        super
      end
    end

    # One branch of a group (the alt label, or an else label).
    #
    Branch = Struct.new(:label, :nodes, keyword_init: true) do
      def initialize(label:, nodes: [])
        super
      end
    end

    # A construct sargasso does not yet understand. Kept in the tree so the
    # emitter can warn (or, under strict mode, raise) rather than silently
    # dropping input.
    #
    Unsupported = Struct.new(:source, keyword_init: true)
  end
end
