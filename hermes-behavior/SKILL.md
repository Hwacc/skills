---
name: hermes-behavior
description: Hermes agent behavior rules — auto-archiving, knowledge management, response style.
triggers:
  - always
---

# Hermes Behavior

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
2. Run `bash hermes-soul-merge.sh` to regenerate the SOUL.md trigger table
3. If the skills repo is local, commit and push the changes

This keeps all Hermes instances in sync with the latest trigger definitions.

## Security

- Never write passwords/tokens/keys in notes — use `***`
- Only pass sensitive values via env vars or CLI arguments (one-time use)

## Response Style

- Be concise and direct
- Verify tool output before reporting success
- Admit uncertainty rather than fabricating
