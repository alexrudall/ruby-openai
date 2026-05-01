# Migration Guides

This page collects maintainer-created migration notes for supported upgrade paths. For the complete release history, see `CHANGELOG.md`.

## General Upgrade Process

1. Upgrade to the latest patch or minor release within your current major version.
2. Review the relevant major-version guide below.
3. Update your application code and Gemfile.
4. Run your test suite against the new version.
5. Open a GitHub issue if a migration path is unclear or missing.

## From 7.x to 8.x

Version 8.0.0 includes breaking changes. Before upgrading, review the `8.0.0` entry in `CHANGELOG.md`.

- Replace `require "ruby/openai"` with `require "openai"`.
- Review Ruby compatibility before upgrading and run your test suite on the Ruby version used by your application.
- HTTP responses are JSON-parsed when possible. If parsing fails, the raw response is returned.
- Unknown file types no longer prevent file upload; the gem raises a warning instead.
- Faraday 1 users no longer need ruby-openai to require `faraday/multipart` on their behalf.
- The `OpenAI-Beta` header was removed from Batches API requests.

## From 6.x to 7.x

Version 7.0.0 included API coverage changes and one removed deprecated endpoint. Before upgrading, review the `7.0.0` and `7.0.1` entries in `CHANGELOG.md`.

- The deprecated edits endpoint was removed.
- Assistants-related APIs were updated for the v2 Assistants beta.
- Batches support was added.
- Base URI handling changed so `/v1/` is not added when the configured base URI already includes it.

## From 5.x to 6.x

Version 6.0.0 included several breaking changes. Before upgrading, review the `6.0.0` entry in `CHANGELOG.md`.

- HTTP errors are raised as `Faraday::Error`, including while streaming.
- Legacy Fine-tunes calls moved to the newer Fine-tuning jobs endpoints.
- Deprecated Completions endpoints were removed in 6.0.0 and later restored as deprecated support in 6.5.0.
- Streaming parameters are preserved instead of being replaced by a boolean.

## From 4.x to 5.x

Version 5.0.0 changed client configuration behavior. Before upgrading, review the `5.0.0` entry in `CHANGELOG.md`.

- Each `OpenAI::Client` now holds its own configuration, enabling multi-tenant use.
- Direct calls to class-level client methods may need to move to instance methods.
- Audio methods moved from the client to the audio namespace: use `client.audio.translate` and `client.audio.transcribe`.

## Older Versions

For older major versions, use `CHANGELOG.md` as the source of truth for breaking changes. If an older upgrade path is important to you and the notes are not clear enough, please open an issue so the migration documentation can be improved.

## Deprecation and Feature Removal

Widely used deprecations and removals are documented in `CHANGELOG.md` and, for major releases, summarized here. When an upstream OpenAI API change forces a shorter deprecation window, the release notes should explain the reason and the migration path.
