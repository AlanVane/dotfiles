#!/usr/bin/env bash

# 打印当前播放条目的标题。
# 有些播放器（如 VLC 播放无 Title 标签的文件）不上报 xesam:title，
# 此时回退为媒体文件名（去掉扩展名、做 URL 解码）。

title=$(playerctl metadata title 2>/dev/null)

if [[ -z $title ]]; then
	url=$(playerctl metadata xesam:url 2>/dev/null)
	name=${url%%\?*}          # 去掉查询串
	name=${name##*/}          # 取 basename
	name=${name%.*}           # 去掉扩展名
	title=$(printf '%b' "$(printf '%s' "$name" | sed 's/%\([0-9A-Fa-f][0-9A-Fa-f]\)/\\x\1/g')")
fi

printf '%s\n' "$title"
