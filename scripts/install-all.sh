#!/bin/bash
# 跨 Agent Skills 统一安装
# 一条命令给所有 agent 装上共享 skills
# 用法: bash scripts/install-all.sh

set -e
DIR="$(cd "$(dirname "$0")/.." && pwd)"

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
bash "$DIR/compile-cursor-skills.sh"

echo ""
echo "── Copilot ──"
echo "  (手动: 复制 templates/copilot-instructions.md 到项目 .github/ 下)"

echo ""
echo "=============================="
echo "  Done."
echo "=============================="
