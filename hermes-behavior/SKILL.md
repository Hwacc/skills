---
name: hermes-behavior
description: Hermes agent behavior rules — knowledge priority, skill lifecycle, response style.
triggers:
  - always
  - updated
  - outdated
  - stale
  - review
---

# Hermes Behavior

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

## Security

- Never write passwords/tokens/keys in notes — use `***`
- Only pass sensitive values via env vars or CLI arguments (one-time use)

## Response Style

- Be concise and direct
- Verify tool output before reporting success
- Admit uncertainty rather than fabricating
