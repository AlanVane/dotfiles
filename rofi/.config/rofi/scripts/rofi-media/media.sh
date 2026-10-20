#! /bin/bash

# Created by Ryan (https://github.com/rxc3202) with inspiration and base code from
# https://github.com/adi1090x

controller="rofi -theme ~/.config/rofi/scripts/rofi-media/media.rasi"
launcher="rofi -theme ~/.config/rofi/scripts/rofi-media/players.rasi"
stop=" Stop"
next=" Next"
previous=" Prev"


playing_status="$(playerctl status)"
if [[ $playing_status == "" ]]; then
    #players="vlc\n"
    mpv="📺 mpv"
    vlc=" vlc"
    options="$mpv\n$vlc\n"
    chosen="$(echo -e "$options" | $launcher -p " Available Players:" -dmenu)"
    case $chosen in
        $mpv)
            exec mpv --player-operation-mode=pseudo-gui
            ;;
        $vlc)
            exec vlc
            ;;
    esac

else
    title=$(media-title.sh)
    artist=$(playerctl metadata artist 2> /dev/null)
    title="${artist:+$artist - }$title"

    # Defines the Play / Pause option content
    if [[ $playing_status == "Paused" ]]; then
        play_pause=" Play"
    else
        play_pause=" Pause"
    fi

    options="$play_pause\n$previous\n$next\n$stop"
    #chosen="$(echo -e "$options" | $rofi_command -p "$title" -dmenu $active $urgent)"
    chosen="$(echo -e "$options" | $controller -p " $title" -dmenu)"
    case $chosen in
        $play_pause)
            # 多媒体播放暂停
            playerctl play-pause
            ;;
        $previous)
            # 多媒体播放上一首
            playerctl previous
            ;;
        $next)
            # 多媒体播放下一首
            playerctl next
            ;;
        $stop)
            # 多媒体播放停止
            playerctl stop
            ;;
    esac

fi

