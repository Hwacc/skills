---
name: hermes-behavior
description: Hermes agent behavior rules — auto-archiving, knowledge management, response style.
triggers:
  - always
  - updated
  - outdated
  - stale
  - review
---

# Hermes Behavior

## Auto-Archive to Obsidian Vault

After completing a task, **automatically** write a summary note:

- New service/tool setup → `基础设施/` config doc
- Bug encountered & fixed → `踩坑记录/` root cause + fix
- Important technical decision → note with rationale
- Newly learned technique/workflow → `技术笔记/`

To find the right directory, read `MOC.md` → `分类目录` section first.
Directories may change — the MOC is the single source of truth.

List written notes after each batch. Do NOT wait for the user to ask.

### After writing new vault notes
Update `MOC.md`:
1. Add the new note as a wikilink under the appropriate category
2. Use the format: `- [[Note Name]] — short description`

## Knowledge Priority

1. Obsidian vault — for all persistent knowledge
2. Memory tool — only for user preferences and connection info

## Skill Lifecycle

After creating or modifying a skill (with `skill_manage` or by writing to the skills repo):

1. Ensure the skill has `triggers:` in its frontmatter
2. Update `HERMES-SOUL.md` trigger table in the repo, commit and push
3. Run `bash hermes-soul-merge.sh` to sync the updated SOUL.md to local
4. Run `hermes skills update` to pull the new/updated skill from the tap

This keeps all Hermes instances in sync with the latest trigger definitions.

## Vault Maintenance

### On session start
1. Read `MOC.md` — scan for ⚠️ markers
2. If stale notes found, tell the user: "N 篇笔记需要审查，要我看看吗？"
3. Do NOT auto-review — wait for user confirmation
4. If user says yes, review one by one: load note → verify facts → update or refresh
5. After reviewing, run `python index.py` to regenerate MOC

### After major discussions or decisions
1. Identify the topic domain (e.g., CouchDB, skills, servers)
2. Search vault for notes mentioning related keywords
3. If facts have changed, update the note with current information
4. List updated notes

### After working on the Hwacc/skills repo
1. Think about which vault notes might be affected by the changes
2. Search vault for those notes by keyword or `skill_deps`
3. If facts changed, patch outdated sections and update `updated` date
4. If note is missing `skill_deps` frontmatter, add it
5. Do NOT skip — repo changes often invalidate related vault notes

## Security

- Never write passwords/tokens/keys in notes — use `***`
- Only pass sensitive values via env vars or CLI arguments (one-time use)

## Response Style

- Be concise and direct
- Verify tool output before reporting success
- Admit uncertainty rather than fabricating
