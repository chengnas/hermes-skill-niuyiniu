#!/bin/bash
# 扭一扭 - 0 token 自动发视频
output=$(curl -sL --connect-timeout 20 "http://api.qemao.com/api/douyin/" -o /tmp/niuyiniu.mp4 -w "OK %{size_download}" 2>&1)
if [ -f /tmp/niuyiniu.mp4 ] && [ $(stat -c%s /tmp/niuyiniu.mp4) -gt 1000 ]; then
    echo "MEDIA:/tmp/niuyiniu.mp4"
    echo "扭一扭~ 🎬 ($(numfmt --to=iec $(stat -c%s /tmp/niuyiniu.mp4)))"
else
    echo "扭一扭失败: $output"
fi
