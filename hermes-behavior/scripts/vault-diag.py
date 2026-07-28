#!/usr/bin/env python
"""Vault Diagnostics — verify vault notes against real-world facts.
Usage: python vault-diag.py [--all] [--skill <name>]
Runs each note's skill_deps check() functions, reports stale findings."""
import os, sys, platform, subprocess, json, importlib.util
from datetime import datetime

CHECKS_DIR = os.path.join(os.path.dirname(__file__), "checks")

def vault_path():
    home = os.path.expanduser("~")
    candidates = [os.path.join(home, "Documents", "Obsidian Vault")]
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
                fm[k.strip()] = v.strip().strip("[]").replace(",", " ").split()
    return fm, content


def load_check_module(skill_name):
    """Load <skill_name>_check.py from checks/ directory."""
    path = os.path.join(CHECKS_DIR, f"{skill_name}_check.py")
    if not os.path.isfile(path):
        return None
    spec = importlib.util.spec_from_file_location(f"{skill_name}_check", path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def diag_note(note_path, vault_root):
    """Run all check() functions for a note's skill_deps. Returns list of findings."""
    fm, content = parse_frontmatter(note_path)
    deps = fm.get("skill_deps", [])
    rel = os.path.relpath(note_path, vault_root)
    findings = []

    for dep in deps:
        mod = load_check_module(dep)
        if mod is None:
            continue
        try:
            results = mod.check(note_path, fm, content)
            for r in results:
                findings.append({
                    "note": rel,
                    "skill": dep,
                    "severity": r.get("severity", "info"),
                    "claim": r.get("claim", ""),
                    "actual": r.get("actual", ""),
                    "suggestion": r.get("suggestion", "")
                })
        except Exception as e:
            findings.append({
                "note": rel,
                "skill": dep,
                "severity": "error",
                "claim": f"check() failed: {e}",
                "actual": "",
                "suggestion": ""
            })
    return findings


if __name__ == "__main__":
    vault = vault_path()
    all_findings = []
    target_skills = set()

    # Parse args
    args = sys.argv[1:]
    scan_all = "--all" in args
    for i, a in enumerate(args):
        if a == "--skill" and i + 1 < len(args):
            target_skills.add(args[i + 1])

    for root, dirs, files in os.walk(vault):
        dirs[:] = [d for d in dirs if not d.startswith(".")]
        for fname in files:
            if not fname.endswith(".md"):
                continue
            path = os.path.join(root, fname)
            fm, _ = parse_frontmatter(path)
            deps = set(fm.get("skill_deps", []))
            if not deps:
                continue

            # Filter by target skills if specified
            if target_skills and not (deps & target_skills):
                continue

            findings = diag_note(path, vault)
            all_findings.extend(findings)

    if not all_findings:
        print("✅ No issues found.")
        sys.exit(0)

    # Group by severity
    stale = [f for f in all_findings if f["severity"] in ("stale", "error")]
    info  = [f for f in all_findings if f["severity"] == "info"]

    if stale:
        print(f"🔴 {len(stale)} issue(s) need attention:\n")
        for f in stale:
            print(f"  [{f['severity'].upper()}] {f['note']}")
            if f["claim"]:
                print(f"    Claim:  {f['claim']}")
            if f["actual"]:
                print(f"    Actual: {f['actual']}")
            if f["suggestion"]:
                print(f"    → {f['suggestion']}")
            print()

    if info:
        print(f"ℹ️  {len(info)} info(s):")
        for f in info:
            print(f"  [{f['skill']}] {f['note']}: {f['suggestion']}")

    sys.exit(1 if stale else 0)
