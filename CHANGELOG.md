# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.1] - 2026-09-03

### Added

- Initial release
- `Sargasso.convert(plantuml_string)` converts PlantUML source to Mermaid source
- Sequence diagram support: messages, participant aliases, dashed/return arrows, `alt`/`else` blocks
- Diagram-agnostic AST (`Parser` -> `AST` -> `Emitters::Mermaid`) so more diagram types and emitters can be added later
- CLI (`sargasso`) with file argument, stdin via `-`, `--quiet`, and `--strict`
- Unsupported PlantUML constructs are reported as warnings by default, or raise `Sargasso::UnsupportedConstructError` under `--strict`
- Minitest suite with golden-file fixtures (`.puml` / `.mmd` pairs)
