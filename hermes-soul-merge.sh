#!/bin/bash
# Hermes SOUL merge — 从 GitHub 拉取基础版并合并本地规则
# 用法: bash hermes-soul-merge.sh

set -e

# 加 cache-bust 防止 CDN 缓存旧版
REPO="https://raw.githubusercontent.com/Hwacc/skills/main/HERMES-SOUL.md?v=$(date +%s)"
# temp 文件放当前目录，避免 MSYS /tmp 路径问题
DL_TMP="./_hermes_soul_dl.md"

# 跨平台 SOUL.md 路径检测
if [ -n "$LOCALAPPDATA" ]; then
    # Windows (git-bash): %LOCALAPPDATA%/hermes/SOUL.md
    HERMES_DIR="${LOCALAPPDATA}/hermes"
elif [ -n "$APPDATA" ]; then
    HERMES_DIR="${APPDATA}/hermes"
elif [ -d "$HOME/.hermes" ]; then
    HERMES_DIR="$HOME/.hermes"
else
    HERMES_DIR="$HOME/.hermes"
fi

LOCAL="${HERMES_DIR}/SOUL.md"
LOCAL_KEEP="${HERMES_DIR}/_soul_local.md"
LOCAL_MARKER='<!-- LOCAL: add machine-specific rules below this line -->'

echo "=== Hermes SOUL Merge ==="
echo "Hermes dir: $HERMES_DIR"

# 1. 备份本地唯一规则 (LOCAL marker 之后的所有内容)
if [ -f "$LOCAL" ]; then
    awk -v marker="$LOCAL_MARKER" '
        $0 == marker {found=1; next}
        found {print}
    ' "$LOCAL" > "$LOCAL_KEEP" 2>/dev/null || true
    local_lines=$(wc -l < "$LOCAL_KEEP" 2>/dev/null || echo 0)
    echo "本地规则已备份: $LOCAL_KEEP ($local_lines lines)"
else
    echo "(本地无 SOUL.md，将新建)"
fi

# 2. 下载 GitHub 基础版
if command -v wget &>/dev/null; then
    wget -q -O "$DL_TMP" "$REPO"
else
    curl -fsSL "$REPO" -o "$DL_TMP"
fi
echo "已下载: HERMES-SOUL.md ($(wc -l < "$DL_TMP") lines)"

# 3. 合并: 基础版 + 本地规则
cat "$DL_TMP" > "$LOCAL"
if [ -f "$LOCAL_KEEP" ] && [ -s "$LOCAL_KEEP" ]; then
    echo "" >> "$LOCAL"
    cat "$LOCAL_KEEP" >> "$LOCAL"
    echo "已合并本地规则"
else
    echo "(无本地规则需要合并)"
fi

rm -f "$DL_TMP" "$LOCAL_KEEP"
echo "Done → $LOCAL"
