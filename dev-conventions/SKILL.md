---
name: dev-conventions
description: Universal security rules and coding conventions for all AI coding assistants.
---

# Development Conventions

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
