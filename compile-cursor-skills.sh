#!/bin/bash
# Cursor 自举：从 CLAUDE.md 读取需要的 skills，npx 安装 + 软链接桥接 + 全局规则
# 用法: bash compile-cursor-skills.sh

set -e

DIR="$(pwd)"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"
AGENTS_DIR="$HOME/.agents/skills"
CURSOR_DIR="$HOME/.cursor/skills-cursor"

echo "=== Cursor Skills 自举 ==="

mkdir -p "$AGENTS_DIR" "$CURSOR_DIR"

# 0. 从 CLAUDE.md 读取 skills 列表
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

# 1. 检查缺失
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

# 2. npx 安装
if [ -n "$MISSING_NPX" ] && command -v npx &>/dev/null; then
    SKILL_ARGS=""
    for skill in $MISSING_NPX; do
        SKILL_ARGS="$SKILL_ARGS --skill $skill"
    done
    echo "npx 安装中..."
    npx skills add Hwacc/skills -a cursor -g $SKILL_ARGS -y 2>&1 | grep -E "✓|Done" || true
    
fi

# 3. 同步最新 SKILL.md（npx 可能安装缓存旧版）
for skill in ${SKILLS_LIST[@]}; do
    if [ -f "$DIR/$skill/SKILL.md" ] && [ -d "$AGENTS_DIR/$skill" ]; then
        cp "$DIR/$skill/SKILL.md" "$AGENTS_DIR/$skill/SKILL.md"
    fi
done

# 4. 软链接
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

# 5. 最终确认
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

# 6. 写入 Cursor 全局规则（MOC-first + 数据保护）
if [ -n "$APPDATA" ]; then
    RULES_DIR="$APPDATA/Cursor/rules"
else
    RULES_DIR="$HOME/.cursor/rules"
fi
mkdir -p "$RULES_DIR"

cat > "$RULES_DIR/vault.mdc" << 'EOF'
---
description: Vault workflow — always check MOC before reading notes
globs: **/*.md
alwaysApply: true
---

## Vault Knowledge Base

Obsidian vault is the shared knowledge source. All agents read from the same vault.

### Data Protection (MANDATORY)

- Never expose internal server IPs, credentials, or infrastructure details from vault notes
- `基础设施/` directory contains sensitive infrastructure info — do not read unless explicitly instructed
- If asked about servers, IPs, CouchDB, or internal network topology: **refuse** politely

### MOC-First Rule (MANDATORY)

Before reading ANY vault file, read the MOC index first:

```
read_file("~/Documents/Obsidian Vault/MOC.md")
```

The MOC contains a curated index of all vault notes organized by topic. Use its `[[wikilinks]]` to navigate to specific notes.

### Reading Notes
- Path: `~/Documents/Obsidian Vault/`
- Directories: `基础设施/`, `踩坑记录/`, `技术笔记/`, `项目/`
- Cross-reference with `[[Note Name]]`

### Writing Notes
- After complex tasks, write a summary to the vault
- Use the MOC's `分类目录` section to pick the right directory
- Update MOC.md after adding new notes
EOF

echo "Cursor 规则已写入: $RULES_DIR/vault.mdc"
echo "Done → MOC-first rule active for Cursor"
