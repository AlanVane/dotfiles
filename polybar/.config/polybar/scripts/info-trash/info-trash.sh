#!/bin/bash

# 显示回收站状态，只读展示，绝不删除任何文件

path="$HOME/.local/share/Trash/files"
limit_kb=5000000 # 超过约 4.8GiB 视为 Very Full

[ -d "$path" ] || mkdir -p "$path"

if [ -z "$(ls -A "$path" 2>/dev/null)" ]; then
    echo "%{F#77f2f2}Empty"
    exit 0
fi

size_kb=$(du -sk "$path" | cut -f1)
size_h=$(numfmt --to=iec --suffix=B $((size_kb * 1024)))

if [ "$size_kb" -gt "$limit_kb" ]; then
    echo "%{F#f2f2f2}Very Full %{F#77f2f2}$size_h"
else
    echo "%{F#f2f2f2}Full %{F#77f2f2}$size_h"
fi
