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

## Setup

The tap only syncs `SKILL.md`. After first install, copy the trace script manually:

```bash
# One-time setup
mkdir -p <skills-dir>/hermes-behavior/scripts
cp <repo>/hermes-behavior/scripts/vault-trace.py <skills-dir>/hermes-behavior/scripts/
```

Or use `write_file` to create it from the source at `hermes-behavior/scripts/vault-trace.py` in the Hwacc/skills repo.

## Auto-Archive to Obsidian Vault

After completing a task, **automatically** write a summary note:

- New service/tool setup → `基础设施/` config doc
- Bug encountered & fixed → `踩坑记录/` root cause + fix
- Important technical decision → note with rationale
- Newly learned technique/workflow → `技术笔记/`

List written notes after each batch. Do NOT wait for the user to ask.

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

### After major discussions or decisions
1. Identify the topic domain (e.g., CouchDB, skills, servers)
2. Search vault for notes mentioning related keywords
3. If facts have changed, update the note with current information
4. List updated notes

### After modifying a skill
1. Run `python <skills-dir>/hermes-behavior/scripts/vault-trace.py <skill-name>` to find affected notes
   - `<skills-dir>` = `$LOCALAPPDATA/hermes/skills` (Windows) or `~/.hermes/skills` (macOS/Linux)
2. Load each affected note
3. Patch outdated sections with current facts
4. Update the note's `updated` frontmatter date

### Weekly (every Sunday)
1. Scan vault notes with no `updated` frontmatter or `updated` > 30 days ago
2. Load the relevant skill for each note's domain (from `skill_deps` frontmatter)
3. Verify factual claims against current reality
4. Update outdated content
5. List all changes in a summary note at `基础设施/周维护报告.md`

## Security

- Never write passwords/tokens/keys in notes — use `***`
- Only pass sensitive values via env vars or CLI arguments (one-time use)

## Response Style

- Be concise and direct
- Verify tool output before reporting success
- Admit uncertainty rather than fabricating
