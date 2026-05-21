# 扭一扭 (Niǔ yī niǔ) — Hermes Agent Skill

随机抖音搞笑短视频投喂，零 AI Token！

```
hermes skills install https://raw.githubusercontent.com/chengnas/hermes-skill-niuyiniu/main/SKILL.md
```

## 功能

- 自动从抖音 API 拉取随机热门短视频
- 零 AI Token：脚本直接取视频，不经过 LLM
- 支持两种模式：
  - **Cron 定时投喂**（推荐）：每天定时推送到聊天窗口
  - **Slash 命令**：输入 `/扭一扭` 随时触发

## 安装

```bash
# 1. 安装 skill
hermes skills install https://raw.githubusercontent.com/chengnas/hermes-skill-niuyiniu/main/SKILL.md

# 2. 安装脚本
mkdir -p ~/.hermes/scripts
cp ~/.hermes/skills/niuyiniu/scripts/niuyiniu.sh ~/.hermes/scripts/
chmod +x ~/.hermes/scripts/niuyiniu.sh

# 3. 创建定时任务（每天 9/12/18 点自动发）
hermes cron create "0 9,12,18 * * *"   --name "扭一扭"   --script niuyiniu.sh   --no-agent   --deliver origin
```

## License

MIT
