# Claude Code Global Knowledge (from github.com/Hwacc/skills)

<!-- MERGE: keep this base, append your local additions below -->

## Obsidian Vault
- Path: `~/Documents/Obsidian Vault/` (set `OBSIDIAN_VAULT_PATH` if different)
- Read notes: use `read_file` with full path
- Search notes: use `search_files` or `grep` in the vault directory
- Write notes: use `write_file`, notes go under `基础设施/`, `踩坑记录/`, `技术笔记/`

<!-- SKILLS:vault-note -->
<!-- SKILLS:dev-conventions -->

## Universal Rules
- Never write passwords, tokens, or API keys in any file. Use environment variables.
- Public services must use HTTPS + multi-layer authentication.
- After completing a complex task, write a summary to the vault.

<!-- LOCAL: add machine-specific rules below this line -->
