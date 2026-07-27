# Hermes Soul — Base (from github.com/Hwacc/skills)

<!-- MERGE: keep this base, append your local additions below -->

## Bootstrap
1. If `hermes-behavior` is not installed, run:
   `hermes skills tap add Hwacc/skills && hermes skills update`
2. Load skills automatically by matching trigger keywords in user requests.

## Universal Rules
3. Never write passwords/tokens/keys in any file.

## Skill Auto-Discovery (from Hwacc/skills tap)

**Available skills and their triggers:**

| Skill | Triggers |
|---|---|
| `dev-conventions` | always |
| `hermes-behavior` | always |
| `infra-couchdb` | CouchDB, couchdb, LiveSync, livesync, 5984, 15984, sync-daemon, vault-push, obsidian-sync |
| `infra-servers` | external-server, internal-server, 192.168.5, 38.244.44.19, "ssh external", "ssh internal" |
| `vault-note` | Obsidian, vault, OBSIDIAN_VAULT_PATH, ".md note" |
| `skills-tap-workflow` | skills tap, tap workflow, "更新 skill 仓库", hermes-soul-merge |

**Auto-discovery chain (execute in order when a trigger matches):**

1. **Check if installed:** if the skill is not in `hermes skills list`, continue.
2. **Search and install:**
   a. **Search:**
      ```bash
      hermes skills search "<trigger-keyword>" --source github
      ```
   b. **If search times out (GitHub API):**
      ```bash
      export GITHUB_TOKEN=$(gh auth token) && hermes skills search "<keyword>" --source github
      ```
   c. **Fallback — if search returns no results or still fails:** install directly from the tap:
      ```bash
      hermes skills install "skills-sh/Hwacc/skills/<skill-name>" -y
      ```
      (Replace `<skill-name>` with the exact skill name from the table above.)
3. **Load and use:**
   ```
   skill_view(name='<skill-name>')
   ```
4. Proceed with the task following the skill's instructions.

<!-- LOCAL: add machine-specific rules below this line -->
