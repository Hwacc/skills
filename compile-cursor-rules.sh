#!/bin/bash
# Cursor 全局规则自举 — 安装 ~/.cursorrules
# 用法: bash compile-cursor-rules.sh

set -e

DIR="$(pwd)"

# Find skills clone (cross-machine)
_find_skills_repo() {
    CACHE="$HOME/.hermes/.skills-repo-path"
    [ -f "$CACHE" ] && [ -d "$(cat "$CACHE")" ] && { cat "$CACHE"; return; }
    if git remote get-url origin 2>/dev/null | grep -q "Hwacc/skills"; then echo "$(pwd)"; return; fi
    for gitdir in $(find "$HOME" -maxdepth 5 -name ".git" -type d 2>/dev/null); do
        dir="$(dirname "$gitdir")"
        git -C "$dir" remote get-url origin 2>/dev/null | grep -q "Hwacc/skills" && { echo "$dir" | tee "$CACHE"; return; }
    done
    [ -d "$(pwd)/vault-note" ] && echo "$(pwd)" && return
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
