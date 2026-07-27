---
name: dev-conventions
description: Universal security rules and coding conventions for all AI coding assistants.
triggers:
  - always
---

# Development Conventions

## Vault Workflow (mandatory)

For any non-trivial task — especially system config, infrastructure, debugging, or architectural decisions:

1. **Search before acting** — search `~/Documents/Obsidian Vault/` for relevant past notes
2. **Act with context** — apply existing knowledge, avoid repeating mistakes
3. **Write after completing** — save a summary to `基础设施/` or `踩坑记录/`

> The vault is shared long-term memory across all agents (Hermes, Claude Code, Cursor). Use it.

## Security

- **Never** write passwords, tokens, or API keys in files. Use environment variables.
- Public services must use HTTPS + multi-layer authentication.
- Do not expose raw SMB/DB ports to the internet.

## Knowledge Management

- Prefer Obsidian vault for persistent knowledge, use memory only for preferences.
- After completing complex tasks, write a summary note to the vault.

## Code Style

- Use descriptive variable names over comments where possible.
- Prefer standard library when sufficient, add deps only with clear justification.
- Test before claiming something works.
