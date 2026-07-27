#!/usr/bin/env python3
"""Vault Trace — find notes affected by a skill change.
Usage: python vault-trace.py <skill-name>"""
import os, sys

VAULT = os.path.expanduser("~/Documents/Obsidian Vault")

def parse_frontmatter(path):
    with open(path) as f:
        content = f.read()
    if not content.startswith("---"):
        return {}
    end = content.find("---", 3)
    if end == -1:
        return {}
    try:
        import yaml
        return yaml.safe_load(content[3:end]) or {}
    except:
        # Fallback: manual parse for skill_deps
        fm = {}
        for line in content[3:end].split("\n"):
            if ":" in line:
                k, v = line.split(":", 1)
                fm[k.strip()] = v.strip().strip("[]").replace(",", " ").split()
        return fm

def trace(skill_name):
    hits = []
    for root, dirs, files in os.walk(VAULT):
        dirs[:] = [d for d in dirs if not d.startswith(".")]
        for fname in files:
            if not fname.endswith(".md"):
                continue
            path = os.path.join(root, fname)
            fm = parse_frontmatter(path)
            deps = fm.get("skill_deps", [])
            if skill_name in deps:
                rel = os.path.relpath(path, VAULT)
                hits.append((rel, fm.get("updated", "unknown")))
    return hits

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python vault-trace.py <skill-name>")
        sys.exit(1)
    results = trace(sys.argv[1])
    if results:
        for note, updated in results:
            print(f"{note}  (updated: {updated})")
    else:
        print(f"No notes depend on '{sys.argv[1]}'")
