# AGENTS.md

Personal Dart monorepo (no Dart workspace). Root has no `pubspec.yaml` — each package is independent.

## Packages

- `cli/` — command-line app. Entrypoint is `bin/cli.dart`; `lib/cli.dart` is untouched template boilerplate (its `calculate()` is only referenced by the test). Depends on `command_runner` via relative path (`../command_runner/`).
- `command_runner/` — local library: a hand-rolled CLI framework (`CommandRunner`, `Command`, `Option`, `ArgResults`). Does **not** use `package:args`.
- `learning/` — NOT a package. Standalone throwaway exercise scripts (Exercism-style: `forth.dart`, `house.dart`, `recite.dart`, ...), each with its own `main()`. `learning/explain.md` documents `forth.dart`. Don't wire these into any package.

## Commands (run from inside the package dir)

- `dart run bin/cli.dart help` — run the CLI (cwd must be `cli/`)
- `dart test` — run tests for that package
- `dart analyze` — lint/typecheck (`package:lints/recommended.yaml`)
- `dart run learning/<file>.dart` — run a learning script (from repo root)
- `.vscode/launch.json` has launch configs for all three (cli, command_runner example, learning)

Because `cli` path-depends on `command_runner`, source edits are picked up without `pub get` (only re-run it if `pubspec.yaml` changes).

## Gotchas

- `command_runner` is WIP: `dart analyze` currently reports 2 errors in `lib/src/command_runner_base.dart` (`parse` can return `null` at line 40; `_removeDash` undefined at line 68), and the options-parsing `while` loop is unfinished. Don't treat a clean analyze as the baseline for it; do keep new code error-free.
- Tests are placeholder stubs (`command_runner/test` has one empty test; `cli/test` only checks `calculate()`).
- `bin/cli.dart` and `arguments.dart`/`command_runner_base.dart` carry `// ignore_for_file: unused_import` — imports above them may be dead.
- Git workflow uses device branches (`feat/laptop-01`, `feat/desktop-01`); master tracks upstream. Commit to the current feature branch, not master.
- `opencode.json` defaults to a local Ollama provider (`ollama/qwen3.5:9b`, baseURL `http://localhost:11434/v1`) — requires Ollama running locally.
