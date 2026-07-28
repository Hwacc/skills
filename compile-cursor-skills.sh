#!/bin/bash
# Cursor 自举：从 CLAUDE.md 读取需要的 skills，npx 安装 + 软链接桥接
# 用法: bash compile-cursor-skills.sh
#
# Skills 列表统一从 CLAUDE.md 的 <!-- SKILLS:xxx --> 标记读取，
# 与 compile-claude-md.sh 保持同步，无需单独维护。

set -e

CLAUDE_MD="$HOME/.claude/CLAUDE.md"
AGENTS_DIR="$HOME/.agents/skills"
CURSOR_DIR="$HOME/.cursor/skills-cursor"

echo "=== Cursor Skills 自举 ==="

# 确保目录存在
mkdir -p "$AGENTS_DIR" "$CURSOR_DIR"

# 0. 从 CLAUDE.md 读取 skills 列表（与 Claude Code 共享同一份定义）
if [ ! -f "$CLAUDE_MD" ]; then
    echo "⚠ CLAUDE.md 不存在，请先运行 compile-claude-md.sh"
    exit 1
fi

SKILLS_LIST=($(grep -o '<!-- SKILLS:[a-z-]* -->' "$CLAUDE_MD" | sed 's/<!-- SKILLS://;s/ -->//' | sort -u))

if [ ${#SKILLS_LIST[@]} -eq 0 ]; then
    echo "⚠ CLAUDE.md 中未发现 <!-- SKILLS:xxx --> 标记"
    exit 1
fi

echo "Skills (from CLAUDE.md): ${SKILLS_LIST[*]}"

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
