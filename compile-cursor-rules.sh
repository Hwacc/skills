#!/bin/bash
# Cursor 全局规则自举 — 安装 ~/.cursorrules
# 用法: bash compile-cursor-rules.sh

set -e

DIR="$(pwd)"
SRC="$DIR/cursor-rules.md"
# Cursor 全局规则目标路径
if [ -n "$APPDATA" ]; then
    DST="$APPDATA/Cursor/.cursorrules"
else
    DST="$HOME/.cursorrules"
fi

echo "=== Cursor 全局规则 ==="

if [ ! -f "$SRC" ]; then
    echo "⚠ cursor-rules.md not found at $SRC"
    exit 1
fi

cp "$SRC" "$DST"
echo "  ✅ cursor-rules → $DST ($(wc -l < "$DST") lines)"
