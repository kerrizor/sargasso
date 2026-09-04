# Sargasso 🌊

**PlantUML goes in, Mermaid comes out.**

The Sargasso Sea is the one stretch of ocean defined by its seaweed rather than
its shores, a floating tangle that catches whatever drifts through. This gem is
that tangle for your diagrams: feed it PlantUML and it hands back the equivalent
Mermaid, so your old diagrams wash up somewhere they can actually be rendered.

```
🧜 PlantUML sequence diagrams -> Mermaid, in pure Ruby
🪸 Parser -> AST -> Emitter, so new diagram types can grow on the reef
🐚 Nothing dropped silently: unknown syntax warns, or raises under --strict
```

It also fills a genuine gap: no Ruby gem does this today, and the wider
ecosystem is thin (a couple of JavaScript tools, some hosted web apps).

Named for the free-floating *Sargassum* seaweed of the Sargasso Sea.

## Why parse the source directly (the no-clean-bridge rationale)

PlantUML never exports a neutral, re-serializable semantic model. Its native
exports are renders (PNG, SVG, PDF), and its structured exports are narrow and
lossy (SCXML for state diagrams only, XMI for class diagrams only). There is no
reliable intermediate format to lean on, so Sargasso parses PlantUML source
directly and emits Mermaid.

## Installation

Install the gem from RubyGems (once published):

```bash
gem install sargasso
```

Or add it to a Gemfile:

```ruby
gem "sargasso"
```

Sargasso is pure Ruby with no Node or JavaScript runtime dependency.

## Usage

```ruby
require "sargasso"

plantuml = <<~PUML
  @startuml
  Alice -> Bob: Hello
  Bob --> Alice: Hi back
  @enduml
PUML

puts Sargasso.convert(plantuml)
```

Output:

```
sequenceDiagram
    Alice->>Bob: Hello
    Bob-->>Alice: Hi back
```

PlantUML `->` maps to Mermaid's solid arrow (`->>`), and `-->` maps to the
dashed arrow (`-->>`). The `@startuml` and `@enduml` markers are stripped, and
message lines are indented under `sequenceDiagram`.

### Unsupported constructs

By default, a construct Sargasso does not understand produces a warning and is
skipped rather than silently dropped. You can collect those warnings, or opt
into strict mode to raise instead:

```ruby
warnings = []
Sargasso.convert(plantuml, warnings: warnings)  # warnings gathered here

Sargasso.convert(plantuml, strict: true)        # raises on the first unsupported construct
```

## CLI

```bash
sargasso path/to/diagram.puml     # convert a file, write Mermaid to stdout
cat diagram.puml | sargasso -     # read from stdin, write to stdout
sargasso --quiet diagram.puml     # suppress warnings
sargasso --strict diagram.puml    # exit non-zero on any unsupported construct
```

## Scope: v1 supports sequence diagrams only

Sequence is the best-covered diagram type across every existing tool, so it is
the v1 target. Other diagram types are not yet supported. The feasibility table
below cross-references the design notes in the idea doc.

| PlantUML diagram | Mermaid target      | Feasibility                       | Status        |
|------------------|---------------------|-----------------------------------|---------------|
| Sequence         | `sequenceDiagram`   | High (proven by pu2mm)            | v1 (this gem) |
| Class            | `classDiagram`      | Medium (partial in other tools)   | planned (v2)  |
| State            | `stateDiagram-v2`   | Medium (SCXML path possible)      | planned (v2)  |
| Activity (beta)  | `flowchart`         | Low/Medium (structural mismatch)  | not planned   |
| Component        | `flowchart`/`graph` | Low (approximate only)            | not planned   |
| Use case         | `flowchart`         | Low (no native Mermaid use-case)  | not planned   |
| ER               | `erDiagram`         | Medium                            | maybe         |
| Gantt            | `gantt`             | Medium                            | maybe         |

The pipeline is structured as `Parser -> AST -> Emitter` so additional diagram
types and additional emitters (for example draw.io) can be added later without
a rewrite.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then run
`rake test` to run the tests and `rake rubocop` to lint. You can also run
`bin/console` for an interactive prompt.

Tests use golden-file fixtures: each pair `test/fixtures/<name>.puml` and
`test/fixtures/<name>.mmd` asserts that converting the PlantUML input produces
the expected Mermaid output.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of notable changes to each release.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/kerrizor/sargasso. See [CONTRIBUTING.md](CONTRIBUTING.md) for
development setup, the `Parser -> AST -> Emitter` architecture, and how to add
support for a new construct or diagram type.

Everyone interacting in the Sargasso project is expected to follow the
[Code of Conduct](CODE_OF_CONDUCT.md).

## License

Available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
