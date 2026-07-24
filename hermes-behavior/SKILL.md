---
name: hermes-behavior
description: Hermes agent behavior rules — auto-archiving, knowledge management, response style.
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

## Security

- Never write passwords/tokens/keys in notes — use `***`
- Only pass sensitive values via env vars or CLI arguments (one-time use)

## Response Style

- Be concise and direct
- Verify tool output before reporting success
- Admit uncertainty rather than fabricating
