#!/bin/bash
# Cursor 全局规则自举 — 安装 ~/.cursorrules
# 用法: bash compile-cursor-rules.sh

set -e

DIR="$(pwd)"

# Find skills clone (cross-machine)
_find_skills_repo() {
    for d in "$(pwd)" "$HOME/skills" "$HOME/workspace/skills"; do
        if [ -d "$d/vault-note" ] && [ -f "$d/vault-note/SKILL.md" ]; then
            echo "$d"
            return
        fi
    done
    echo "$(pwd)"
}
DIR="$(_find_skills_repo)"

SRC="$DIR/cursor-rules.md"
DST="$HOME/.cursorrules"

echo "=== Cursor 全局规则 ==="

if [ ! -f "$SRC" ]; then
    echo "⚠ cursor-rules.md not found at $SRC"
    exit 1
fi

cp "$SRC" "$DST"
echo "  ✅ cursor-rules → $DST ($(wc -l < "$DST") lines)"
