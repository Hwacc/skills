#!/bin/bash
# 跨 Agent Skills 统一安装
# 一条命令给所有 agent 装上共享 skills
# 用法: bash scripts/install-all.sh

set -e

# Find skills clone (cross-machine)
DIR="$(cd "$(dirname "$0")/.." && pwd)"
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

echo "=============================="
echo "  跨 Agent Skills 统一安装"
echo "=============================="

echo ""
echo "── Hermes ──"
hermes skills tap add Hwacc/skills 2>/dev/null && hermes skills update && echo "  ✅ hermes skills 已更新" || echo "  ⚠ hermes 未安装或已是最新"

echo ""
echo "── Claude Code ──"
bash "$DIR/compile-claude-md.sh"

echo ""
echo "── Cursor ──"
bash "$DIR/compile-cursor-rules.sh"
bash "$DIR/compile-cursor-skills.sh"

echo ""
echo "── Copilot ──"
echo "  (手动: 复制 templates/copilot-instructions.md 到项目 .github/ 下)"

echo ""
echo "=============================="
echo "  Done."
echo "=============================="
