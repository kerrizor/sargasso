# frozen_string_literal: true

require_relative "ast"

module Sargasso
  # Parses PlantUML sequence-diagram source into Sargasso::AST nodes.
  #
  # v1 is deliberately line-oriented: PlantUML sequence syntax is largely
  # line-based, so a set of per-line matchers gets us a useful walking skeleton
  # fast. The AST layer sits between this and the emitter so a real grammar can
  # replace this parser later without touching emitters.
  #
  class Parser
    # Matches a message line: "A -> B: text" or "A --> B : text".
    # Group 1: source, 2: arrow, 3: target, 4: optional text.
    #
    MESSAGE = /\A(\S+)\s*(-+>+)\s*(\S+)\s*(?::\s*(.*))?\z/

    # Matches a participant/actor declaration, with optional quoted label and
    # "as" alias:
    #   participant Bob
    #   participant "Bob B." as B
    #   actor Alice
    # Group 1: keyword, 2: quoted name (optional), 3: bare name (optional),
    # 4: alias (optional).
    #
    PARTICIPANT = /\A(participant|actor)\s+(?:"([^"]+)"|(\S+))(?:\s+as\s+(\S+))?\z/i

    ALT = /\Aalt\b\s*(.*)\z/i
    ELSE = /\Aelse\b\s*(.*)\z/i
    END_GROUP = /\Aend\b\z/i

    def initialize(source)
      @source = source
    end

    def parse
      diagram = AST::Diagram.new(kind: :sequence)
      # Stack of node lists; the top is where new nodes are appended. Groups
      # (alt/else) push a new branch's node list onto this stack.
      #
      @stack = [diagram.nodes]

      each_significant_line do |line|
        parse_line(line)
      end

      diagram
    end

    private

    def each_significant_line
      @source.each_line do |raw|
        line = raw.strip
        next if line.empty?
        next if line.start_with?("@startuml", "@enduml")
        next if line.start_with?("'") # PlantUML single-line comment

        yield line
      end
    end

    def parse_line(line)
      case line
      when ALT then start_alt(Regexp.last_match(1))
      when ELSE then start_else(Regexp.last_match(1))
      when END_GROUP then end_group
      when PARTICIPANT then push_participant(Regexp.last_match)
      when MESSAGE then push_message(Regexp.last_match)
      else current << AST::Unsupported.new(source: line)
      end
    end

    def push_participant(match)
      quoted = match[2]
      bare = match[3]
      alias_name = match[4]

      # With an alias, the alias is the id and the name is the label. Without
      # one, the name (quoted or bare) is the id and there is no separate label.
      #
      participant = if alias_name
                      AST::Participant.new(id: alias_name, label: quoted || bare)
                    else
                      AST::Participant.new(id: quoted || bare, label: nil)
                    end

      current << participant
    end

    def push_message(match)
      arrow = match[2].include?("--") ? :dashed : :solid
      current << AST::Message.new(
        from: match[1],
        to: match[3],
        text: match[4].to_s.strip,
        arrow: arrow
      )
    end

    def start_alt(label)
      alt = AST::Alt.new
      branch = AST::Branch.new(label: label.strip)
      alt.branches << branch
      current << alt
      @open_alts ||= []
      @open_alts << alt
      @stack.push(branch.nodes)
    end

    def start_else(label)
      # Replace the current branch's node list with a new else branch.
      #
      @stack.pop
      alt = @open_alts.last
      branch = AST::Branch.new(label: label.strip)
      alt.branches << branch
      @stack.push(branch.nodes)
    end

    def end_group
      @stack.pop
      @open_alts&.pop
    end

    def current
      @stack.last
    end
  end
end
