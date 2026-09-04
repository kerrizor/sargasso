# Contributing to Sargasso

Thanks for your interest in contributing to Sargasso! This document covers how to get started.

## Development Setup

```bash
git clone https://github.com/kerrizor/sargasso.git
cd sargasso
bundle install
```

## Running Tests

```bash
bundle exec rake test
```

Or run the full default task (tests plus RuboCop):

```bash
bundle exec rake
```

All tests must pass and RuboCop must be clean before submitting a PR.

## Code Style

- Use `frozen_string_literal: true` at the top of all Ruby files
- Follow standard Ruby conventions (enforced by RuboCop)
- Keep methods small and focused
- Add tests for new functionality
- No em-dashes in prose (use commas, parentheses, or restructure)

## Architecture

Sargasso converts diagrams through a three-stage pipeline:

```
PlantUML source -> Sargasso::Parser -> Sargasso::AST -> Sargasso::Emitters::Mermaid -> Mermaid source
```

- **`Sargasso::Parser`** turns PlantUML source into AST nodes.
- **`Sargasso::AST`** is a diagram-agnostic set of structs (`Diagram`, `Participant`, `Message`, `Alt`, `Branch`, `Unsupported`). It knows nothing about PlantUML or Mermaid syntax.
- **`Sargasso::Emitters::Mermaid`** turns AST nodes into Mermaid source.

Keeping the AST neutral is what lets new diagram types and new emitters (for example draw.io or graphviz) slot in without a rewrite. When you add support for a construct, add the AST node first, then teach the parser to produce it and the emitter to render it.

## Adding Support for a New Construct

The most common contribution is teaching Sargasso a PlantUML construct it does not yet understand (currently these become `AST::Unsupported` and produce a warning). Each addition is three coordinated changes plus a fixture pair.

### 1. Add or reuse an AST node

If the construct needs new structure, add a struct to `lib/sargasso/ast.rb`. Keep it source-agnostic and target-agnostic. For example, a note might be:

```ruby
# A note attached to one or more participants.
#
# position is a neutral placement: :left, :right, or :over.
#
Note = Struct.new(:position, :participants, :text, keyword_init: true)
```

### 2. Teach the parser to produce it

In `lib/sargasso/parser.rb`, match the PlantUML line and build the AST node instead of falling through to `AST::Unsupported`.

### 3. Teach the emitter to render it

In `lib/sargasso/emitters/mermaid.rb`, handle the new node type and emit the equivalent Mermaid syntax. If Mermaid has no equivalent, record a warning (or raise `Sargasso::UnsupportedConstructError` under strict mode) rather than dropping it silently.

### 4. Add a golden-file fixture pair

Add a matching pair under `test/fixtures/`:

- `test/fixtures/my_construct.puml` (the PlantUML input)
- `test/fixtures/my_construct.mmd` (the expected Mermaid output)

Then assert the conversion in `test/test_sargasso.rb`:

```ruby
def test_my_construct
  assert_fixture_converts("my_construct")
end
```

### 5. Update documentation

- Update the feature/feasibility table in `README.md` if coverage changed
- Add a changelog entry under `[Unreleased]`

## Adding a New Diagram Type

Sequence diagrams are the only supported type in v1. Adding another type (class, state, ER, and so on) follows the same pattern at a larger scale: add the AST nodes it needs, add a parser path that recognizes the diagram's opening syntax, and add emitter cases that render it. See the feasibility ranking in the README and in the idea doc for which types map cleanly to Mermaid.

## Pull Request Process

1. **Branch naming**: Use `your-username/description` (for example `kerrizor/support-notes`)

2. **Changelog**: Add an entry to `CHANGELOG.md` under `[Unreleased]`:
   ```markdown
   ### Added
   - **Notes** - `note left/right/over` now converts to Mermaid notes
   ```

3. **Tests**: Ensure `bundle exec rake` passes (tests plus RuboCop)

4. **PR description**: Explain what the change does and why

## Questions?

Open an issue if you have questions or want to discuss a feature before implementing it.
