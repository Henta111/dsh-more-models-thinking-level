# Changelog

All notable changes to dsh-more-models-thinking-level are documented in this file.
The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

## [Unreleased]

## [0.1.1] - 2026-08-25

### Changed
- Expanded `enable-capabilities.ps1` from the `gpt-*`, `codex-*` and `gemini-*` prefixes to all non-image model IDs, including custom gateway IDs.
- Documented the required one-time helper invocation after an npm/profile installation.
- Preserved existing `reasoningEfforts` declarations and the `gpt-image-*` exclusion.
- Made repeated helper runs byte-stable instead of appending an extra newline.

## [0.1.0] - 2026-08-24

### Added
- Bundle manifest (`cordis.patch.yml`), host entry (`lib/index.js`) and web client entry (`lib/client.js`).
- Per-model `reasoningEfforts` declarations for GPT, Codex and Gemini models.
- Client settings section explaining how reasoning levels map to provider-native wire values.
- Install / uninstall / enable-capabilities / disable-capabilities PowerShell helpers.
- Marketplace metadata: `repository`, `homepage`, `bugs`, `keywords`, `license`.
