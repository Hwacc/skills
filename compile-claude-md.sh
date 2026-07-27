#!/bin/bash
# Claude Code CLAUDE.md merge — 从 GitHub 拉取基础版、注入 skill 内容、合并本地规则
# 用法: bash compile-claude-md.sh

set -e

REPO="https://raw.githubusercontent.com/Hwacc/skills/main/CLAUDE.md?v=$(date +%s)"
DL_TMP="./_claude_md_dl.md"

# 跨平台路径检测
if [ -n "$LOCALAPPDATA" ]; then
    CLAUDE_DIR="${LOCALAPPDATA}/claude"
elif [ -d "$HOME/.claude" ]; then
    CLAUDE_DIR="$HOME/.claude"
else
    mkdir -p "$HOME/.claude"
    CLAUDE_DIR="$HOME/.claude"
fi

LOCAL="${CLAUDE_DIR}/CLAUDE.md"
LOCAL_KEEP="${CLAUDE_DIR}/_claude_local.md"
LOCAL_MARKER='<!-- LOCAL: add machine-specific rules below this line -->'

echo "=== Claude Code CLAUDE.md Merge ==="
echo "Claude dir: $CLAUDE_DIR"

# 1. 备份本地规则
if [ -f "$LOCAL" ]; then
    awk -v marker="$LOCAL_MARKER" '
        $0 == marker {found=1; next}
        found {print}
    ' "$LOCAL" > "$LOCAL_KEEP" 2>/dev/null || true
    echo "本地规则已备份: $(wc -l < "$LOCAL_KEEP" 2>/dev/null || echo 0) lines"
fi

# 2. 下载 GitHub 基础版
if command -v wget &>/dev/null; then
    wget -q -O "$DL_TMP" "$REPO"
else
    curl -fsSL "$REPO" -o "$DL_TMP"
fi
echo "已下载: CLAUDE.md ($(wc -l < "$DL_TMP") lines)"

# 3. 扫描 skills 目录，注入 skill 内容
SKILLS_DIR=""
for d in "./" "$HOME/skills" "$HOME/workspace/skills"; do
    if [ -d "$d/vault-note" ] && [ -f "$d/vault-note/SKILL.md" ]; then
        SKILLS_DIR="$d"
        break
    fi
done

if [ -n "$SKILLS_DIR" ]; then
    echo "发现 skills 仓库: $SKILLS_DIR"

    # 注入每个 skill
    for skill in vault-note dev-conventions; do
        SKILL_FILE="$SKILLS_DIR/$skill/SKILL.md"
        if [ -f "$SKILL_FILE" ]; then
            # 提取 SKILL.md 正文（跳过 frontmatter）
            BODY=$(awk '/^---$/{c++; next} c==1 && /^[^ ]/{if(!body)body=1} body' "$SKILL_FILE")
            ESCAPED=$(echo "$BODY" | sed 's/\\/\\\\/g; s/&/\\&/g; s/\//\\\//g' | tr '\n' '\r' | sed 's/\r/\\n/g')
            sed -i '' "s|<!-- SKILLS:${skill} -->|<!-- SKILLS:${skill} -->\\n\\n${ESCAPED}|" "$DL_TMP" 2>/dev/null || \
            sed -i "s|<!-- SKILLS:${skill} -->|<!-- SKILLS:${skill} -->\\n\\n${ESCAPED}|" "$DL_TMP"
            echo "  已注入: $skill"
        fi
    done
fi

# 4. 合并
cat "$DL_TMP" > "$LOCAL"
if [ -f "$LOCAL_KEEP" ] && [ -s "$LOCAL_KEEP" ]; then
    echo "" >> "$LOCAL"
    cat "$LOCAL_KEEP" >> "$LOCAL"
    echo "已合并本地规则"
fi

rm -f "$DL_TMP" "$LOCAL_KEEP"
echo "Done → $LOCAL"
