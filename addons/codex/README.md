# Codex add-on

This add-on installs a pinned Codex CLI release and portable non-personal configuration in the development container.

Included configuration:

- `config.toml`: model, reasoning, documentation, web search, personality, and agent defaults.

Excluded local state:

- Personal global instructions, prompts, and authored skills.
- Authentication and credential files.
- Project trust records and machine-specific paths.
- Histories, sessions, memories, attachments, logs, databases, caches, and shell snapshots.
- Generated approval rules, system skills, plugin packages, and plugin caches.

Set `addons.codex.enabled` in `config.yaml` to control installation. Update the pinned release and installer SHA-256 together after reviewing the current official installer.
