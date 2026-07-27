#!/usr/bin/env python
"""Vault Trace — find notes affected by a skill change.
Usage: python vault-trace.py <skill-name>"""
import os, sys, platform


def vault_path():
    """Cross-platform vault path resolution."""
    home = os.path.expanduser("~")
    candidates = [
        os.path.join(home, "Documents", "Obsidian Vault"),
        os.path.join(home, "Documents", "Obsidian Vault"),  # macOS/Linux
    ]
    # Windows: %USERPROFILE%/Documents/Obsidian Vault
    if platform.system() == "Windows":
        candidates.insert(0, os.path.join(os.environ.get("USERPROFILE", home),
                                          "Documents", "Obsidian Vault"))
    for p in candidates:
        if os.path.isdir(p):
            return p
    return candidates[0]  # fallback


def parse_frontmatter(path):
    with open(path, encoding="utf-8") as f:
        content = f.read()
    if not content.startswith("---"):
        return {}
    end = content.find("---", 3)
    if end == -1:
        return {}
    try:
        import yaml
        return yaml.safe_load(content[3:end]) or {}
    except Exception:
        # Fallback: manual parse for skill_deps
        fm = {}
        for line in content[3:end].split("\n"):
            if ":" in line:
                k, v = line.split(":", 1)
                k = k.strip()
                v = v.strip().strip("[]").replace(",", " ").split()
                fm[k] = v
        return fm


def trace(skill_name, vault):
    hits = []
    for root, dirs, files in os.walk(vault):
        dirs[:] = [d for d in dirs if not d.startswith(".")]
        for fname in files:
            if not fname.endswith(".md"):
                continue
            path = os.path.join(root, fname)
            fm = parse_frontmatter(path)
            deps = fm.get("skill_deps", [])
            if skill_name in deps:
                rel = os.path.relpath(path, vault)
                hits.append((rel, fm.get("updated", "unknown")))
    return hits


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python vault-trace.py <skill-name>")
        sys.exit(1)
    vault = vault_path()
    results = trace(sys.argv[1], vault)
    if results:
        for note, updated in results:
            print(f"{note}  (updated: {updated})")
    else:
        print(f"No notes depend on '{sys.argv[1]}'")
