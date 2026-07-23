# Changelog

## 0.2.0

- Redesign the public API around idiomatic Ruby naming and current Anki “note type” terminology.
- Normalize nested wrapper inputs from snake_case to AnkiConnect wire keys.
- Add wrappers for all nondeprecated actions in AnkiConnect commit `de6e6e1`.
- Fix the `findAndReplaceInModels` request shape and media-only note updates.
- Add local argument validation for note selectors, media sources, tags, and parallel card values.
- Add HTTP and HTTPS endpoint support, configurable timeouts, protocol validation, and typed errors.
- Require HTTPS when sending API keys to non-loopback endpoints and stop exposing configured keys through a reader.
- Separate safe unit tests from explicit live integration tests and test Ruby 3.4 and 4.0 in CI.
