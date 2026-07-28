# Cursor Global Rules

## Vault Workflow

### On session start
1. Read `MOC.md` — scan for ⚠️ markers
2. If stale notes found, tell the user: "N 篇笔记需要审查，要我看看吗？"
3. Wait for user confirmation before reviewing

### Before acting
1. Search the vault for relevant past notes (`search_files` or read MOC)
2. Apply existing knowledge, avoid repeating past mistakes

### Auto-Archive (filtered)

Only archive when the result has cross-session reuse value:

| Archive | Skip |
|---------|------|
| Bug root cause analysis | Fixing the bug itself |
| Architecture decisions (why this approach) | Routine code refactoring |
| Pitfalls (config traps, counter-intuitive behavior) | Writing unit tests |
| New tool or process introduction | One-line CSS/typo fixes |

Do NOT archive infrastructure changes, operational records, or regular code changes.

### Vault note maintenance after repo work

After working on the Hwacc/skills repository:

1. Search vault for notes with matching `skill_deps` or topic keywords
2. Load each affected note
3. If facts changed, patch outdated sections
4. Update the `updated` frontmatter date
5. Do NOT skip — repo changes often invalidate related vault notes

## Obsidian Vault
- Path: `~/Documents/Obsidian Vault/` (set `OBSIDIAN_VAULT_PATH` if different)
- Read: `read_file`, Search: `search_files` or `grep` in vault directory, Write: `write_file`
- **Directories**: Read `MOC.md` → `分类目录` section — this is the single source of truth
- Cross-reference with `[[Note Name]]`

## Security

- Never write passwords, tokens, or API keys in any file. Use environment variables.

### Company Data Protection

Vault notes MUST NOT contain company project sensitive information: business code, access keys, secrets, unreleased requirements, internal URLs, or proprietary configs. When in doubt, use a generic description or the `***` placeholder.
