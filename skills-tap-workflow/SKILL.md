---
name: skills-tap-workflow
description: Hwacc/skills 个人 tap 仓库的完整使用和维护链路——触发→安装→使用 + 修改→推送→合并。
triggers:
  - skills tap
  - tap workflow
  - "更新 skill 仓库"
  - hermes-soul-merge
---

# Skills Tap 工作流

## 仓库结构

```
Hwacc/skills/
├── HERMES-SOUL.md          # SOUL 基础模板（分发给所有 Hermes 实例）
├── hermes-soul-merge.sh    # 本地合并脚本（拉取上游 + 保留本地规则）
├── dev-conventions/        # SKILL.md
├── hermes-behavior/        # SKILL.md
├── infra-couchdb/          # SKILL.md
├── infra-servers/          # SKILL.md
├── vault-note/             # SKILL.md
└── skills-tap-workflow/    # SKILL.md
```

## 核心链路：触发 → 安装 → 使用

```
用户输入含关键词
       │
       ▼
SOUL.md 触发表匹配 skill 名
       │
       ▼
skills_list 检查是否已安装
       │
   ┌───┴───┐
  已安装   未安装
   │       │
   ▼       ▼
直接加载  ① search --source github
          │
      ┌───┴───┐
     成功    超时/无结果
      │       │
      ▼       ▼
   安装     ② GITHUB_TOKEN 重试
              │
          ┌───┴───┐
         成功    仍失败
          │       │
          ▼       ▼
       安装     ③ fallback: direct install
                  │
                  ▼
               skill_view → 执行
```

## 维护链路

```
修改 GitHub → push → bash hermes-soul-merge.sh → 本地 SOUL.md 更新
```

## 新机器初始化

```bash
hermes skills tap add Hwacc/skills
hermes skills update
bash hermes-soul-merge.sh
```
