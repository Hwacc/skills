#!/usr/bin/env python
"""Index generator — scan vault, build MOC.md with stale markers.
Usage: python index.py  (run from repo root or anywhere)
Reads OBSIDIAN_VAULT_PATH env var, falls back to ~/Documents/Obsidian Vault."""
import os, sys, platform, re, time
from datetime import datetime

MOC_HEADER = """---
updated: {date}
skill_deps: [vault-note]
---

# MOC

> 快速索引，[[wikilink]] 直达每篇笔记 · ⚠️ = 需审查
"""

CATEGORY_ORDER = ["基础设施", "同步与 Agent", "Skills 体系", "维护机制",
                   "踩坑记录", "技术笔记", "项目", "远期规划"]

# Map vault directories to MOC categories
DIR_CATEGORY = {
    "基础设施": "基础设施",
    "踩坑记录": "踩坑记录",
    "技术笔记": "技术笔记",
    "项目": "项目",
}

def vault_path():
    home = os.path.expanduser("~")
    env = os.environ.get("OBSIDIAN_VAULT_PATH", "")
    if env and os.path.isdir(env):
        return env
    for p in [os.path.join(home, "Documents", "Obsidian Vault")]:
        if os.path.isdir(p):
            return p
    return os.path.join(home, "Documents", "Obsidian Vault")


def parse_note(path):
    """Return {title, dir, tags, skill_deps, stale_after, updated, description}."""
    with open(path, encoding="utf-8", errors="ignore") as f:
        content = f.read()
    fm = {}
    if content.startswith("---"):
        end = content.find("---", 3)
        if end != -1:
            try:
                import yaml
                fm = yaml.safe_load(content[3:end]) or {}
            except Exception:
                for line in content[3:end].split("\n"):
                    if ":" in line:
                        k, v = line.split(":", 1)
                        v = v.strip().strip("[]").replace(",", " ").split()
                        fm[k.strip()] = v

    # Title from first # heading
    title = os.path.splitext(os.path.basename(path))[0]
    m = re.search(r'^#\s+(.+)$', content, re.MULTILINE)
    if m:
        title = m.group(1).strip()

    # Description from frontmatter or tags
    desc = ""
    if "description" in fm and isinstance(fm.get("description"), str):
        desc = str(fm["description"])
    elif "tags" in fm and isinstance(fm.get("tags"), list) and fm["tags"]:
        desc = ", ".join(str(t) for t in fm["tags"])

    return {
        "title": title,
        "path": os.path.basename(path),
        "dir": os.path.basename(os.path.dirname(path)),
        "tags": fm.get("tags", []),
        "skill_deps": fm.get("skill_deps", []),
        "stale_after": fm.get("stale_after", None),
        "updated": fm.get("updated", None),
        "description": desc,
    }


def is_stale(stale_after):
    """Check if stale_after date has passed."""
    if not stale_after:
        return False
    try:
        dt = datetime.strptime(str(stale_after)[:10], "%Y-%m-%d")
        return datetime.now() > dt
    except (ValueError, TypeError):
        return False


def build_moc(vault):
    today = datetime.now().strftime("%Y-%m-%d")
    moc = MOC_HEADER.format(date=today)
    notes = []
    misc_notes = []

    for root, dirs, files in os.walk(vault):
        dirs[:] = [d for d in dirs if not d.startswith(".")]
        for fname in files:
            if not fname.endswith(".md") or fname == "MOC.md":
                continue
            path = os.path.join(root, fname)
            note = parse_note(path)
            note["stale"] = is_stale(note["stale_after"])
            notes.append(note)

    # Group by category
    categorized = {c: [] for c in CATEGORY_ORDER}
    for note in notes:
        cat = DIR_CATEGORY.get(note["dir"], None)
        if cat:
            categorized.setdefault(cat, []).append(note)
        else:
            misc_notes.append(note)

    # Output sections in order
    for cat_name in CATEGORY_ORDER:
        items = categorized.get(cat_name, [])
        if not items:
            continue
        moc += f"\n\n## {cat_name}\n\n"
        # Sort: stale first, then by title
        items.sort(key=lambda n: (not n["stale"], n["title"]))
        for n in items:
            prefix = "⚠️ " if n["stale"] else ""
            desc = f" — {n['description']}" if n["description"] else ""
            moc += f"- {prefix}[[{n['title']}]]{desc}\n"

    if misc_notes:
        moc += "\n\n## 其他\n\n"
        for n in sorted(misc_notes, key=lambda n: n["title"]):
            moc += f"- [[{n['title']}]]\n"

    # Append 分类目录 (from existing MOC or default)
    moc += f"""

---

## 分类目录

| 目录 | 用途 |
|------|------|
| `基础设施/` | 部署、架构、服务器、skills、同步 |
| `踩坑记录/` | Bug、误报、配置陷阱 |
| `技术笔记/` | 调研、学习、方案分析 |
| `项目/` | 项目相关 |

> 自动生成于 {today} · `python index.py`
"""

    return moc


if __name__ == "__main__":
    vault = vault_path()
    moc_content = build_moc(vault)

    output = os.path.join(vault, "MOC.md")
    with open(output, "w", encoding="utf-8") as f:
        f.write(moc_content)

    stale_count = moc_content.count("⚠️ ") - 1  # subtract header mention
    print(f"MOC.md generated ({stale_count} stale notes)")
    if stale_count:
        print("Run with review to see which notes need attention.")
