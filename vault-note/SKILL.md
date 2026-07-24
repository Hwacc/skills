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

Read from `OBSIDIAN_VAULT_PATH` env var. Set it in `~/.hermes/.env`:
- macOS/Linux: `~/Documents/Obsidian Vault/`
- Windows: `C:/Users/用户名/Documents/Obsidian Vault/`

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

## Rules

- `[[Note Name]]` for cross-references
- Never include passwords/tokens/keys — use `***`
