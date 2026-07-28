#!/bin/bash
# Hermes SOUL merge — 从 GitHub 拉取基础版、扫描本地 skills 更新触发表、合并本地规则
# 用法: bash hermes-soul-merge.sh

set -e

REPO="https://raw.githubusercontent.com/Hwacc/skills/main/HERMES-SOUL.md?v=$(date +%s)"
DL_TMP="./_hermes_soul_dl.md"

# Cross-platform Python
_python() {
    python3 "$@" 2>/dev/null || python "$@"
}

# 跨平台 SOUL.md 路径检测
if [ -n "$LOCALAPPDATA" ]; then
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

# 1. 备份本地规则
if [ -f "$LOCAL" ]; then
    awk -v marker="$LOCAL_MARKER" '
        $0 == marker {found=1; next}
        found {print}
    ' "$LOCAL" > "$LOCAL_KEEP" 2>/dev/null || true
    echo "本地规则已备份: $LOCAL_KEEP ($(wc -l < "$LOCAL_KEEP" 2>/dev/null || echo 0) lines)"
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

# 3. 扫描本地 skills 仓库，重建触发表
SKILLS_DIR=""
for d in "./skills" "$HOME/skills" "$HOME/workspace/skills" "$HERMES_DIR/skills"; do
    if [ -d "$d" ] && compgen -G "$d/*/SKILL.md" > /dev/null 2>&1; then
        SKILLS_DIR="$d"
        break
    fi
done

if [ -n "$SKILLS_DIR" ]; then
    echo "发现 skills 仓库: $SKILLS_DIR"

    TABLE=$(_python -c "
import os, glob
rows = ''
for md in sorted(glob.glob('$SKILLS_DIR/*/SKILL.md')):
    name = os.path.basename(os.path.dirname(md))
    with open(md) as f:
        content = f.read()
    triggers = []
    in_triggers = False
    for line in content.split('\n'):
        if line.strip() == 'triggers:':
            in_triggers = True
            continue
        if in_triggers:
            if line.startswith('  - '):
                triggers.append(line.strip()[2:].strip('\"'))
            elif line.strip() and not line.startswith(' '):
                break
    trigger_str = ', '.join(triggers) if triggers else '(no triggers)'
    rows += '| {} | {} |\n'.format(name, trigger_str)
print(rows.strip())
")

    if [ -n "$TABLE" ]; then
        _python -c "
import re
content = open('$DL_TMP').read()
table = '''$TABLE'''
new_table = '| Skill | Triggers |\n|---|---|\n' + table
content = re.sub(
    r'\| Skill \| Triggers \|[\s\S]*?(?=\n## |\n<!-- |\Z)',
    '\n' + new_table + '\n',
    content, count=1
)
open('$DL_TMP', 'w').write(content)
"
        echo "触发表已更新"
    fi
fi

# 4. 合并
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
