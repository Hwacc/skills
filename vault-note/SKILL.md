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

**Always start with the MOC index.** Before reading or searching individual notes, read `MOC.md` first. It contains a curated index of all vault notes organized by topic — faster than full-text search.

- **Read MOC**: `read_file` with vault path + `/MOC.md`
- **Read note**: `read_file` with full path (from MOC wikilinks)
- **Search**: `search_files` with `target: "content"` or `target: "files"` + `*.md` glob
- **Write**: `write_file` with full path. After writing, update MOC.

## Directory Convention

Read `MOC.md` → `分类目录` section for the current directory list and their purposes.
This is the single source of truth — directories may change over time.
Agent picks the best-matching directory based on note content.

## Language Convention

Skills (SKILL.md) → **English** (reader is AI, more precise, fewer tokens)
Vault notes (.md in Obsidian) → **中文** (reader is human, user's native language)

## Frontmatter (mandatory)

Every vault note MUST include:

```yaml
---
tags: [topic1, topic2]
skill_deps: [vault-note, ...]   # which skills this note depends on
stale_after: YYYY-MM-DD         # review after this date (set automatically)
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

### stale_after rules

Agent sets `stale_after` based on content type:

| Content type | stale_after | Rationale |
|-------------|-------------|-----------|
| Metrics, status, doc counts (CouchDB, etc.) | +2 weeks | Ops data changes fast |
| Architecture design, server config | +6 months | Infrastructure is stable |
| Bug fix, pitfall record | omit | Historical record, never "expires" |
| Tech research, solution analysis | +1 month | Tech stacks evolve |

After writing a note, update MOC with `python index.py`.

## Rules

- `[[Note Name]]` for cross-references
- **Never include company sensitive info** — no business code, access keys, secrets, unreleased requirements, internal URLs, or proprietary configs. Use `***` placeholder or generic descriptions.
