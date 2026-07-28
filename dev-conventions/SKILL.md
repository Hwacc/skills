---
name: dev-conventions
description: Universal rules for all AI coding assistants — security, vault workflow, knowledge management.
triggers:
  - always
---

# Development Conventions

## Vault Workflow (mandatory)

For any non-trivial task — especially system config, infrastructure, debugging, or architectural decisions:

1. **Search before acting** — search `~/Documents/Obsidian Vault/` for relevant past notes
2. **Act with context** — apply existing knowledge, avoid repeating mistakes
3. **Write after completing** — save a summary to the vault

> The vault is shared long-term memory across all agents (Hermes, Claude Code, Cursor). Use it.

### Auto-Archive

After completing a task, write a summary note:

| Task type | Directory |
|-----------|-----------|
| New service/tool setup | `基础设施/` |
| Bug encountered & fixed | `踩坑记录/` |
| Important technical decision | `基础设施/` |
| Newly learned technique/workflow | `技术笔记/` |

To find the right directory, read `MOC.md` → `分类目录` section first.
Directories may change — the MOC is the single source of truth.

### After writing a vault note

Update `MOC.md`:
1. Add the new note as a wikilink under the appropriate category
2. Use format: `- [[Note Name]] — short description`
3. Run `python <repo>/hermes-behavior/scripts/index.py` to regenerate MOC (index.py is in the Hwacc/skills repo, not in the skills directory)

### On session start

1. Read `MOC.md` — scan for ⚠️ markers
2. If stale notes found, tell the user: "N 篇笔记需要审查，要我看看吗？"
3. Wait for user confirmation before reviewing
4. After reviewing, run `python <repo>/hermes-behavior/scripts/index.py` to regenerate MOC

### After major discussions or decisions

1. Identify the topic domain
2. Search vault for notes mentioning related keywords
3. If facts have changed, update the note with current information
4. List updated notes

### After working on the Hwacc/skills repo

1. Think about which vault notes might be affected
2. Search vault for those notes by keyword or `skill_deps`
3. If facts changed, patch outdated sections and update `updated` date
4. If note is missing `skill_deps` frontmatter, add it
5. Do NOT skip — repo changes often invalidate related vault notes

## Security

- **Never** write passwords, tokens, or API keys in files. Use environment variables.
- Public services must use HTTPS + multi-layer authentication.
- Do not expose raw SMB/DB ports to the internet.

### Company Data Protection

**Vault notes MUST NOT contain company project sensitive information**, including but not limited to:

- Business-related source code or code snippets
- Access keys, API keys, secrets, or passwords (use `***` placeholder)
- Internal business requirements or unreleased feature specifications
- Customer data, internal URLs, or proprietary configuration values

General architecture patterns, infrastructure design, and personal tooling are fine.
When in doubt, **do not write it** — prefer a generic description over a specific one.

## Knowledge Management

- Prefer Obsidian vault for persistent knowledge, use memory only for preferences.
- After completing complex tasks, write a summary note to the vault.

## Code Style

- Use descriptive variable names over comments where possible.
- Prefer standard library when sufficient, add deps only with clear justification.
- Test before claiming something works.
