# Claude Code Global Knowledge

## Vault Workflow (mandatory)

For any non-trivial task — especially system config, infrastructure, debugging, or architectural decisions:

1. **Search before acting** — search the vault for relevant past notes before starting
2. **Act with context** — apply existing knowledge, avoid repeating mistakes
3. **Write after completing** — save a summary to `基础设施/` or `踩坑记录/`

> This mirrors Hermes's `hermes-behavior` auto-archive pattern. The vault is your long-term memory across sessions and agents.

### After modifying Hwacc/skills repo files

When you change scripts, configs, or CLAUDE.md in the Hwacc/skills repo:

1. Search vault for notes with matching `skill_deps` or topic keywords
2. Load each affected note
3. If facts have changed, patch outdated sections
4. Update the `updated` frontmatter date
5. Do NOT skip this — even "just script changes" can invalidate vault notes

## Obsidian Vault
- Path: `~/Documents/Obsidian Vault/` (set `OBSIDIAN_VAULT_PATH` if different)
- Read: `read_file`, Search: `search_files` or `grep` in vault directory, Write: `write_file`
- Directories: `基础设施/` (infra), `踩坑记录/` (bugs), `技术笔记/` (tech), `项目/` (projects)
- Cross-reference with `[[Note Name]]`

## Active Skills
- vault-note — Read/write/search Obsidian vault notes
- dev-conventions — Security rules + coding standards (always active)
<!-- SKILLS:vault-note -->
<!-- SKILLS:dev-conventions -->

## Security
- Never write passwords, tokens, or API keys in any file. Use environment variables.
- Public services must use HTTPS + multi-layer authentication.

<!-- LOCAL: add machine-specific rules below this line -->
