     1|---
     2|name: niuyiniu
     3|description: "Use when the user wants random funny short videos (扭一扭) from Douyin. Zero-token delivery via slash command hook or cron schedule without LLM involvement."
     4|version: 1.0.0
     5|author: 冒险家 TIM + Hermes Agent
     6|license: MIT
     7|platforms: [linux, macos]
     8|metadata:
     9|  hermes:
    10|    tags: [fun, video, douyin, cron, zero-token, entertainment]
    11|    related_skills: []
    12|---
    13|
    14|# 扭一扭 (Niǔ yī niǔ) — Random Funny Videos
    15|
    16|摇一摇式的随机短视频投喂。通过公开抖音 API 拉取热门搞笑短视频，零 AI token 直接投送到你的聊天窗口。支持两种模式：**slash 命令**（手动触发）和 **cron 定时**（自动投喂）。
    17|
    18|> "扭一扭" = 像扭蛋机一样，随机扭一个视频出来
    19|
    20|## How It Works
    21|
    22|```
    23|User types /扭一扭 (or cron triggers)
    24|         │
    25|         ▼
    26|   Gateway hook intercepts
    27|         │
    28|         ▼
    29|   Shell script fetches video from http://api.qemao.com/api/douyin/
    30|         │
    31|         ▼
    32|   Output: MEDIA:/tmp/niuyiniu.mp4
    33|         │
    34|         ▼
    35|   Video delivered to chat — 0 AI tokens burned
    36|```
    37|
    38|## When to Use
    39|
    40|- 群聊活跃气氛，定时发搞笑视频
    41|- 个人娱乐，随机刷短视频
    42|- 学习 Hermes 的 zero-token hook/cron 模式
    43|
    44|Don't use for: 正经内容推送、新闻监控（这 API 只返回随机搞笑短视频）。
    45|
    46|## Quick Start
    47|
    48|### 1. 安装脚本
    49|
    50|```bash
    51|mkdir -p ~/.hermes/scripts
    52|curl -o ~/.hermes/scripts/niuyiniu.sh https://raw.githubusercontent.com/chengnas/hermes-skill-niuyiniu/main/scripts/niuyiniu.sh
    53|chmod +x ~/.hermes/scripts/niuyiniu.sh
    54|```
    55|
    56|### 2. 测试脚本
    57|
    58|```bash
    59|bash ~/.hermes/scripts/niuyiniu.sh
    60|# 输出: MEDIA:/tmp/niuyiniu.mp4
    61|#       扭一扭~ 🎬 (3.2M)
    62|```
    63|
    64|### 3A. 方案一：定时投喂（推荐，零门槛）
    65|
    66|直接用 cron `no_agent` 模式，不需要改代码：
    67|
    68|```bash
    69|hermes cron create "0 9,12,18 * * *" \
    70|  --name "扭一扭" \
    71|  --script niuyiniu.sh \
    72|  --no-agent \
    73|  --deliver origin
    74|```
    75|
    76|每天 9:00、12:00、18:00 自动推一个视频。
    77|
    78|### 3B. 方案二：Slash 命令（需要改源码）
    79|
    80|适合想输入 `/扭一扭` 随时触发的用户。需要两步。
    81|
    82|**Step 1: 注册 slash 命令**
    83|
    84|在 `hermes_cli/commands.py` 的 `COMMAND_REGISTRY` 中添加：
    85|
    86|```python
    87|CommandDef("扭一扭", "随机扭一个搞笑短视频", "Fun", gateway_only=True),
    88|```
    89|
    90|**Step 2: 创建 hook**
    91|
    92|```bash
    93|mkdir -p ~/.hermes/hooks/niuyiniu
    94|```
    95|
    96|创建 `HOOK.yaml`：
    97|
    98|```yaml
    99|name: niuyiniu
   100|description: "Keyword trigger: 扭一扭 → run script directly without AI"
   101|events:
   102|  - command:扭一扭
   103|```
   104|
   105|创建 `handler.py`：
   106|
   107|```python
   108|"""扭一扭 hook — 拦截 /扭一扭，直接跑脚本不走 AI"""
   109|import subprocess
   110|import os
   111|
   112|async def handle(event_type: str, context: dict):
   113|    script = os.path.expanduser("~/.hermes/scripts/niuyiniu.sh")
   114|    try:
   115|        result = subprocess.run(
   116|            ["bash", script],
   117|            capture_output=True, text=True, timeout=60,
   118|        )
   119|        output = result.stdout.strip()
   120|        if output and "MEDIA:" in output:
   121|            return {"decision": "handled", "message": output}
   122|        return {"decision": "handled", "message": "扭一扭失败，待会儿再试~"}
   123|    except Exception as e:
   124|        return {"decision": "handled", "message": f"扭一扭出错: {e}"}
   125|```
   126|
   127|**Step 3: 重启 Gateway**
   128|
   129|```bash
   130|sudo systemctl restart hermes-gateway
   131|```
   132|
   133|重启后在任意聊天里输入 `/扭一扭` 即可。
   134|
   135|## API Dependency
   136|
   137|视频来源：`http://api.qemao.com/api/douyin/`
   138|
   139|- 免费公开 API
   140|- 返回随机热门抖音短视频（MP4 直链）
   141|- 文件大小通常 2-5 MB
   142|- 无需 API key
   143|- 偶尔挂掉（境外可能需要代理）
   144|
   145|## Common Pitfalls
   146|
   147|1. **API 超时**: `curl --connect-timeout 20` 已设置 20 秒超时，挂掉时报错不卡死。
   148|2. **空文件**: 脚本检查文件大小 > 1000 bytes 才发送，防止发空视频。
   149|3. **MEDIA 路径必须用绝对路径**: `/tmp/niuyiniu.mp4` 是绝对路径，不要用 `~` 或相对路径。
   150|4. **Gateway 重启超时**: `hermes gateway restart` 可能在等待活动 session 结束时超时。直接用 `sudo systemctl restart hermes-gateway`。
   151|5. **境外访问**: 如果 API 被墙，把 curl 请求走代理：`curl --socks5-hostname 127.0.0.1:1080`。
   152|6. **Slash 命令必须在 COMMAND_REGISTRY 中注册**，否则 gateway 在 hook 触发前就会拒绝请求。
   153|7. **cron 不够快**: cron 最小粒度是 1 分钟。如果想实时触发，用方案二。
   154|
   155|## Verification Checklist
   156|
   157|- [ ] `bash ~/.hermes/scripts/niuyiniu.sh` 能正常输出 `MEDIA:/tmp/niuyiniu.mp4`
   158|- [ ] `/tmp/niuyiniu.mp4` 文件大小 > 1KB
   159|- [ ] cron 方案：`hermes cron run <job_id>` 手动触发一次，确认视频送达
   160|- [ ] hook 方案：重启 gateway 后日志显示 `1 hook(s) loaded: niuyiniu`
   161|- [ ] hook 方案：发送 `/扭一扭` 后收到视频
   162|- [ ] hook 方案：日志中无 AI 调用（`grep "model_call"` 无匹配）= 确认 0 token
   163|
   164|## Customization
   165|
   166|### 更换视频源
   167|
   168|修改 `niuyiniu.sh` 中的 URL：
   169|
   170|```bash
   171|# 换成其他免费视频 API
   172|output=$(curl -sL --connect-timeout 20 "https://your-api.com/random-video" -o /tmp/niuyiniu.mp4 -w "OK %{size_download}" 2>&1)
   173|```
   174|
   175|### 调整定时频率
   176|
   177|```bash
   178|hermes cron edit <job_id>
   179|# 修改 schedule，比如改成 "0 */2 * * *" (每2小时)
   180|```
   181|
   182|### 添加视频描述
   183|
   184|脚本最后一行的 echo 就是发送的文字描述，改它：
   185|
   186|```bash
   187|echo "你的专属扭一扭来啦~ 🎬 ($(numfmt --to=iec $(stat -c%s /tmp/niuyiniu.mp4)))"
   188|```
   189|