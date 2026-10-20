#!/usr/bin/env bash

status_function () {
	if playerctl status > /dev/null; then
			title=$(media-title.sh)
			title=${title:-"[Unknown]"}
			artist=$(playerctl metadata artist 2> /dev/null)
			artist=${artist:-"[Unknown]"}
			(( ${#title} > 25 )) && title="${title:0:25}…"
			(( ${#artist} > 25 )) && artist="${artist:0:25}…"
			if [[ $artist == "[Unknown]" ]]; then
				echo "$(playerctl status -f "{{playerName}}"): $title ($(playerctl status))"
			else
				echo "$(playerctl status -f "{{playerName}}"): $title by $artist ($(playerctl status))"
			fi
	else
		echo "Nothing is playing"
	fi
}
status=$(status_function)

# Options
toggle="⏯️ Play/Pause"
next="⏭️ Next"
prev="⏮ Previous"
seekminus="⏪ Go back 15 seconds"
seekplus="⏩ Go ahead 15 seconds"
switch="🔄 Change selected player"

# Variable passed to rofi
options="$toggle\n$next\n$prev\n$seekplus\n$seekminus\n$switch"

chosen="$(echo -e "$options" | rofi -show -p "${status^}" -dmenu -selected-row 0)"
case $chosen in
    $toggle)
		playerctl play-pause
        ;;
    $next)
		playerctl next
        ;;
    $prev)
        playerctl previous
        ;;
    $seekminus)
		playerctl position 15-
        ;;
    $seekplus)
		playerctl position 15+
        ;;
    $switch)
        playerctld shift
        ;;
esac
