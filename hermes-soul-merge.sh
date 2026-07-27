#!/bin/bash
# Hermes SOUL merge — 从 GitHub 拉取基础版并合并本地规则
# 用法: bash hermes-soul-merge.sh

set -e

REPO="https://raw.githubusercontent.com/Hwacc/skills/main/HERMES-SOUL.md"
LOCAL="$HOME/.hermes/SOUL.md"
LOCAL_KEEP="$HOME/.hermes/SOUL.local.md"
TMP="/tmp/HERMES-SOUL.md"

echo "=== Hermes SOUL Merge ==="

# 1. 备份本地唯一规则
if [ -f "$LOCAL" ]; then
    awk '/<!-- LOCAL: -->/{found=1; next} found' "$LOCAL" > "$LOCAL_KEEP" 2>/dev/null
    echo "本地规则已备份: $LOCAL_KEEP ($(wc -l < "$LOCAL_KEEP" 2>/dev/null || echo 0) lines)"
fi

# 2. 下载 GitHub 基础版
curl -fsSL "$REPO" -o "$TMP"
echo "已下载: HERMES-SOUL.md ($(wc -l < "$TMP") lines)"

# 3. 合并
cat "$TMP" > "$LOCAL"
if [ -f "$LOCAL_KEEP" ] && [ -s "$LOCAL_KEEP" ]; then
    echo "" >> "$LOCAL"
    cat "$LOCAL_KEEP" >> "$LOCAL"
    echo "已合并本地规则"
fi

rm -f "$TMP"
echo "Done → $LOCAL"
