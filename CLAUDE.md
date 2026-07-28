# Claude Code Global Knowledge

## Vault Workflow (mandatory)

**Trigger** — run this workflow when a task involves ANY of: system config, infrastructure, debugging, architecture decisions, or 3rd-party integration — OR is expected to take more than ~15 min. Skip only for trivial one-off edits.

1. **Search before acting** — search the vault for relevant past notes BEFORE writing code
2. **Act with context** — apply existing knowledge, avoid repeating past mistakes
3. **Write after completing** — save a summary to `基础设施/`, `踩坑记录/`, `技术笔记/`, or `项目/`

Do NOT skip step 1 or step 3.

> This mirrors Hermes's `hermes-behavior` auto-archive pattern. The vault is your long-term memory across sessions and agents.

### Vault note maintenance after repo work

After working on the Hwacc/skills repository (any file: scripts, markdown, shell):

1. Search vault for notes with matching `skill_deps` or topic keywords
2. Load each affected note
3. If facts changed, patch outdated sections
4. Update the `updated` frontmatter date
5. Do NOT skip — repo changes often invalidate related vault notes

## Obsidian Vault
- Path: `~/Documents/Obsidian Vault/` (set `OBSIDIAN_VAULT_PATH` if different)
- Read: `read_file`, Search: `search_files` or `grep` in vault directory, Write: `write_file`
- **Directories**: Read `MOC.md` → `分类目录` section — this is the single source of truth, may change
- Cross-reference with `[[Note Name]]`

## Active Skills
- vault-note — Read/write/search Obsidian vault notes
- dev-conventions — Security rules + coding standards (always active)
<!-- SKILLS:vault-note -->
<!-- SKILLS:dev-conventions -->

## Security

- Never write passwords, tokens, or API keys in any file. Use environment variables.
- Public services must use HTTPS + multi-layer authentication.

### Company Data Protection

Vault notes MUST NOT contain company project sensitive information: business code, access keys, secrets, unreleased requirements, internal URLs, or proprietary configs. When in doubt, use a generic description or the `***` placeholder.

<!-- LOCAL: add machine-specific rules below this line -->
