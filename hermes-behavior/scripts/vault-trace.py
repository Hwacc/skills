#!/usr/bin/env python
"""Vault Trace — find notes affected by a skill change, with stale detection.
Usage:
  python vault-trace.py <skill-name>           # list affected notes
  python vault-trace.py <skill-name> --stale   # exit 1 if any note updated >24h ago
  python vault-trace.py --all --stale          # check ALL skills at once
"""
import os, sys, platform, time
from datetime import datetime, timedelta

SKILLS = ["vault-note", "skills-tap-workflow", "hermes-behavior",
          "dev-conventions", "infra-couchdb", "infra-servers"]

# Keyword hints for content-based fallback (notes without skill_deps)
SKILL_KEYWORDS = {
    "vault-note": ["vault-note", "obsidian", "vault", "知识库", "笔记规范"],
    "skills-tap-workflow": ["skills tap", "tap workflow", "自举", "skill 仓库", "SOUL.md"],
    "hermes-behavior": ["hermes-behavior", "auto-archive", "自动归档", "周维护"],
    "dev-conventions": ["dev-conventions", "company data", "公司数据", "安全规则"],
    "infra-couchdb": ["couchdb", "livesync", "couchdb.raxium", "CouchDB"],
    "infra-servers": ["frp", "ssh", "192.168", "服务器"],
}

STALE_HOURS = 24


def vault_path():
    home = os.path.expanduser("~")
    candidates = [
        os.path.join(home, "Documents", "Obsidian Vault"),
    ]
    if platform.system() == "Windows":
        candidates.insert(0, os.path.join(os.environ.get("USERPROFILE", home),
                                          "Documents", "Obsidian Vault"))
    for p in candidates:
        if os.path.isdir(p):
            return p
    return candidates[0]


def parse_frontmatter(path):
    with open(path, encoding="utf-8") as f:
        content = f.read()
    if not content.startswith("---"):
        return {}, content
    end = content.find("---", 3)
    if end == -1:
        return {}, content
    try:
        import yaml
        fm = yaml.safe_load(content[3:end]) or {}
    except Exception:
        fm = {}
        for line in content[3:end].split("\n"):
            if ":" in line:
                k, v = line.split(":", 1)
                k = k.strip()
                v = v.strip().strip("[]").replace(",", " ").split()
                fm[k] = v
    return fm, content


def is_stale(updated_str):
    """Check if updated date is more than STALE_HOURS ago."""
    if not updated_str or updated_str == "unknown":
        return True
    try:
        dt = datetime.strptime(str(updated_str)[:10], "%Y-%m-%d")
        return datetime.now() - dt > timedelta(hours=STALE_HOURS)
    except ValueError:
        return True


def content_match(content, skill_name):
    """Fallback: check if note content mentions skill-related keywords."""
    keywords = SKILL_KEYWORDS.get(skill_name, [skill_name])
    content_lower = content.lower()
    return any(kw.lower() in content_lower for kw in keywords)


def trace(skill_name, vault):
    hits = []
    missing_deps = []
    for root, dirs, files in os.walk(vault):
        dirs[:] = [d for d in dirs if not d.startswith(".")]
        for fname in files:
            if not fname.endswith(".md"):
                continue
            path = os.path.join(root, fname)
            fm, content = parse_frontmatter(path)
            deps = fm.get("skill_deps", [])
            rel = os.path.relpath(path, vault)
            updated = fm.get("updated", "unknown")

            if skill_name in deps:
                hits.append((rel, updated))
            elif not deps and content_match(content, skill_name):
                missing_deps.append((rel, updated))

    return hits, missing_deps


if __name__ == "__main__":
    check_stale = "--stale" in sys.argv
    check_block = "--block" in sys.argv
    all_skills = "--all" in sys.argv
    args = [a for a in sys.argv[1:] if not a.startswith("--")]

    if all_skills:
        skill_list = SKILLS
    elif len(args) == 1:
        skill_list = [args[0]]
    else:
        print("Usage: python vault-trace.py <skill-name> [--stale] [--block]")
        print("       python vault-trace.py --all --stale")
        sys.exit(1)

    vault = vault_path()
    stale_found = False

    for skill in skill_list:
        hits, missing = trace(skill, vault)

        if check_stale:
            for note, updated in hits:
                if is_stale(updated):
                    stale_found = True
                    print(f"[STALE] {note}  (updated: {updated}, skill: {skill})")
            for note, updated in missing:
                if is_stale(updated):
                    stale_found = True
                    print(f"[STALE+NO_DEPS] {note}  (updated: {updated}, skill: {skill}) — add skill_deps")
        else:
            if hits:
                for note, updated in hits:
                    print(f"  {note}  (updated: {updated})")
            if missing:
                print(f"  ⚠ content match (no skill_deps):")
                for note, updated in missing:
                    print(f"    {note}  (updated: {updated})")
            if not hits and not missing:
                print(f"No notes depend on '{skill}'")

    if check_stale and stale_found:
        if check_block:
            print("\n⛔ Push blocked: vault notes are outdated.")
            sys.exit(1)
        else:
            print("\n⚠ Some vault notes are outdated. Review before pushing.")
            print("   Use --block to enforce blocking.")
    elif check_stale:
        print("✅ All vault notes up to date.")
