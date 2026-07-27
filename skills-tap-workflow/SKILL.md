---
name: skills-tap-workflow
description: Full lifecycle of the Hwacc/skills personal tap — trigger→install→use, plus maintain→push→merge.
triggers:
  - skills tap
  - tap workflow
  - "更新 skill 仓库"
  - hermes-soul-merge
---

# Skills Tap Workflow

## Repo Structure

```
Hwacc/skills/
├── HERMES-SOUL.md          # SOUL base template (distributed to all Hermes instances)
├── hermes-soul-merge.sh    # Local merge script (pull upstream + preserve local rules)
├── dev-conventions/        # SKILL.md
├── hermes-behavior/        # SKILL.md
├── infra-couchdb/          # SKILL.md
├── infra-servers/          # SKILL.md
├── vault-note/             # SKILL.md
└── skills-tap-workflow/    # SKILL.md
```

## Core Chain: Trigger → Install → Use

```
User input with keyword
       │
       ▼
SOUL.md trigger table matches skill name
       │
       ▼
skills_list checks if installed
       │
   ┌───┴───┐
  Yes      No
   │       │
   ▼       ▼
Load      ① search --source github
directly    │
        ┌───┴───┐
       OK      Timeout/no results
        │       │
        ▼       ▼
     Install  ② GITHUB_TOKEN retry
                 │
             ┌───┴───┐
            OK      Still fail
             │       │
             ▼       ▼
          Install  ③ fallback: direct install
                       │
                       ▼
                    skill_view → execute
```

**Key design**: Step ③ fallback bypasses GitHub search API entirely,
constructing install path as `skills-sh/Hwacc/skills/<name>`. Zero-blocking.

## Maintenance Chain

```
Modify GitHub → git push → bash hermes-soul-merge.sh → local SOUL.md updated
```

## New Machine Bootstrap

```bash
hermes skills tap add Hwacc/skills
hermes skills update
bash hermes-soul-merge.sh
```
