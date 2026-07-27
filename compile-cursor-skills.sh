#!/bin/bash
# Cursor 自举：安装原生 skills + 桥接到 ~/.cursor/skills-cursor/
# 用法: bash compile-cursor-skills.sh
#
# Cursor 的 skills 在 ~/.cursor/skills-cursor/ 下自动发现
# 但 npx skills add -a cursor 只装到 ~/.agents/skills/，不会自动复制
# 此脚本做两件事：npx 安装 + 软链接桥接

set -e

SKILLS_LIST=(vault-note dev-conventions)
AGENTS_DIR="$HOME/.agents/skills"
CURSOR_DIR="$HOME/.cursor/skills-cursor"

echo "=== Cursor Skills 自举 ==="

# 确保目录存在
mkdir -p "$AGENTS_DIR" "$CURSOR_DIR"

# 1. 检查哪些 skills 缺失
MISSING_NPX=""
MISSING_LINK=""
INSTALLED=""

for skill in "${SKILLS_LIST[@]}"; do
    has_npx=false
    has_link=false

    [ -f "$AGENTS_DIR/$skill/SKILL.md" ] && has_npx=true
    [ -L "$CURSOR_DIR/$skill" ] && [ -f "$CURSOR_DIR/$skill/SKILL.md" ] && has_link=true

    if $has_npx && $has_link; then
        INSTALLED="$INSTALLED $skill"
    else
        $has_npx || MISSING_NPX="$MISSING_NPX $skill"
        $has_link || MISSING_LINK="$MISSING_LINK $skill"
    fi
done

[ -n "$INSTALLED" ]  && echo "  ✅ 已就绪:$INSTALLED"
[ -n "$MISSING_NPX" ] && echo "  ⬜ 需 npx 安装:$MISSING_NPX"
[ -n "$MISSING_LINK" ]&& echo "  ⬜ 需软链接:$MISSING_LINK"

# 2. npx 安装缺失的
if [ -n "$MISSING_NPX" ] && command -v npx &>/dev/null; then
    SKILL_ARGS=""
    for skill in $MISSING_NPX; do
        SKILL_ARGS="$SKILL_ARGS --skill $skill"
    done
    echo "npx 安装中..."
    npx skills add Hwacc/skills -a cursor -g $SKILL_ARGS -y 2>&1 | grep -E "✓|Done" || true
fi

# 3. 软链接缺失的
if [ -n "$MISSING_LINK" ]; then
    for skill in $MISSING_LINK; do
        if [ -d "$AGENTS_DIR/$skill" ]; then
            ln -sf "$AGENTS_DIR/$skill" "$CURSOR_DIR/$skill"
            echo "  已链接: $skill"
        else
            echo "  ⚠ $skill: npx 源不存在，跳过硬链接"
        fi
    done
fi

# 4. 最终确认
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Cursor skills:"
for skill in "${SKILLS_LIST[@]}"; do
    if [ -f "$CURSOR_DIR/$skill/SKILL.md" ]; then
        echo "  ✅ $skill"
    else
        echo "  ❌ $skill (缺失)"
    fi
done
echo "━━━━━━━━━━━━━━━━━━━━━━━━"
