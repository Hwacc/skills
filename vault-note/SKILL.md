---
name: vault-note
description: Read, write, and search notes in the shared Obsidian vault across all AI tools.
triggers:
  - Obsidian
  - vault
  - OBSIDIAN_VAULT_PATH
  - ".md note"
---

# Vault Note

Access the shared Obsidian vault for reading and writing knowledge notes.

## Vault Path

Read from `OBSIDIAN_VAULT_PATH` env var. Default paths:
- macOS/Linux: `~/Documents/Obsidian Vault/`
- Windows: `%USERPROFILE%/Documents/Obsidian Vault/`

Resolve the env var before passing to file tools — they don't expand shell variables.

## Operations

- **Read**: `read_file` with full path
- **Search**: `search_files` with `target: "content"` or `target: "files"` + `*.md` glob
- **Write**: `write_file` with full path

## Directory Convention

- `基础设施/` — Infrastructure & deployment
- `踩坑记录/` — Bugs & fixes
- `技术笔记/` — Technical knowledge
- `项目/` — Project notes

## Language Convention

Skills (SKILL.md) → **English** (reader is AI, more precise, fewer tokens)
Vault notes (.md in Obsidian) → **中文** (reader is human, user's native language)

- `[[Note Name]]` for cross-references
- Never include passwords/tokens/keys — use `***`
