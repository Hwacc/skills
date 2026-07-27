#!/bin/bash
# Claude Code 自举：拉取 CLAUDE.md + 安装原生 skills
# 用法: bash compile-claude-md.sh
#
# 策略: skills 不再注入 CLAUDE.md 文本，改为 npx skills 原生安装到 ~/.claude/skills/
# CLAUDE.md 只保留 vault 路径 + 通用规则 + 本地定制

set -e

REPO="https://api.github.com/repos/Hwacc/skills/contents/CLAUDE.md"
DL_TMP="./_claude_md_dl.md"
DL_JSON="./_claude_md_raw.json"

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
SKILLS_DIR="${CLAUDE_DIR}/skills"
LOCAL_KEEP="${CLAUDE_DIR}/_claude_local.md"
LOCAL_MARKER='<!-- LOCAL: add machine-specific rules below this line -->'

echo "=== Claude Code 自举 ==="
echo "Claude dir: $CLAUDE_DIR"

# 1. 备份本地规则
if [ -f "$LOCAL" ]; then
    awk -v marker="$LOCAL_MARKER" '
        $0 == marker {found=1; next}
        found {print}
    ' "$LOCAL" > "$LOCAL_KEEP" 2>/dev/null || true
    echo "本地规则已备份: $(wc -l < "$LOCAL_KEEP" 2>/dev/null || echo 0) lines"
fi

# 2. 下载 GitHub 基础版 CLAUDE.md（通过 API，不走 CDN 缓存）
if command -v wget &>/dev/null; then
    wget -q -O "$DL_JSON" "$REPO"
else
    curl -fsSL -H "Accept: application/vnd.github.v3+json" "$REPO" -o "$DL_JSON"
fi
# 从 JSON 中提取 base64 内容并解码
python3 -c "
import json, base64, sys
with open('$DL_JSON') as f:
    data = json.load(f)
content = base64.b64decode(data['content']).decode('utf-8')
with open('$DL_TMP', 'w') as f:
    f.write(content)
" 2>/dev/null || {
    # fallback: python3 不可用时用 python
    python -c "
import json, base64
with open('$DL_JSON') as f:
    data = json.load(f)
content = base64.b64decode(data['content']).decode('utf-8')
with open('$DL_TMP', 'w') as f:
    f.write(content)
"
}
echo "已下载: CLAUDE.md ($(wc -l < "$DL_TMP") lines)"

# 3. 从 CLAUDE.md 中解析需要的 skills 列表
EXPECTED_SKILLS=$(grep -o '<!-- SKILLS:[a-z-]* -->' "$DL_TMP" | sed 's/<!-- SKILLS://;s/ -->//' | sort -u)
if [ -z "$EXPECTED_SKILLS" ]; then
    echo "⚠ 未在 CLAUDE.md 中发现 <!-- SKILLS:xxx --> 标记，跳过 skill 安装"
else
    echo "期望 skills: $(echo "$EXPECTED_SKILLS" | tr '\n' ' ')"

    # 检查哪些已安装、哪些缺失
    MISSING=""
    INSTALLED=""
    for skill in $EXPECTED_SKILLS; do
        if [ -f "$SKILLS_DIR/$skill/SKILL.md" ]; then
            INSTALLED="$INSTALLED $skill"
        else
            MISSING="$MISSING $skill"
        fi
    done

    [ -n "$INSTALLED" ] && echo "  ✅ 已安装:$(echo "$INSTALLED" | sed 's/ / /g')"
    [ -n "$MISSING" ]   && echo "  ⬜ 缺失:$(echo "$MISSING" | sed 's/ / /g')"

    # 只安装缺失的
    if [ -n "$MISSING" ] && command -v npx &>/dev/null; then
        SKILL_ARGS=""
        for skill in $MISSING; do
            SKILL_ARGS="$SKILL_ARGS --skill $skill"
        done
        echo "安装中..."
        npx skills add Hwacc/skills -a claude-code -g $SKILL_ARGS -y 2>&1 | grep -E "✓|Installed|Done" || true
        echo "  → 安装完成"
    elif [ -z "$MISSING" ]; then
        echo "  → 全部已就绪，无需安装"
    fi
fi

# 4. 合并: 基础版 + 本地规则
cp "$DL_TMP" "$LOCAL"
if [ -f "$LOCAL_KEEP" ] && [ -s "$LOCAL_KEEP" ]; then
    echo "" >> "$LOCAL"
    echo "$LOCAL_MARKER" >> "$LOCAL"
    cat "$LOCAL_KEEP" >> "$LOCAL"
    echo "已合并本地规则"
fi

rm -f "$DL_TMP" "$DL_JSON" "$LOCAL_KEEP"

# 5. 最终确认
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━"
echo "CLAUDE.md → $LOCAL"
echo "Skills    → $SKILLS_DIR/"
if [ -d "$SKILLS_DIR" ]; then
    for skill in $(ls "$SKILLS_DIR" 2>/dev/null); do
        echo "  $( [ -f "$SKILLS_DIR/$skill/SKILL.md" ] && echo '✅' || echo '⚠' ) $skill"
    done
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━"
