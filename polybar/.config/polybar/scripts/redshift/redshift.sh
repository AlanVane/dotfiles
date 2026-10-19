#!/bin/sh
# 红移开关与色温的持久化状态存放在 stateFile（机器本地，不进 dotfiles 仓库），
# envFile 只提供出厂默认值，二者均缺失时使用内置默认。

envFile=~/.config/polybar/scripts/env.sh
stateFile=${XDG_STATE_HOME:-$HOME/.local/state}/redshift
changeValue=300

REDSHIFT=on
REDSHIFT_TEMP=6500
[ -r "$envFile" ] && . "$envFile"
[ -r "$stateFile" ] && . "$stateFile"

save_state() {
    mkdir -p "$(dirname "$stateFile")"
    printf 'REDSHIFT=%s\nREDSHIFT_TEMP=%s\n' "$REDSHIFT" "$REDSHIFT_TEMP" >"$stateFile"
}

change_mode() {
    REDSHIFT=$1
    save_state
}

change_temp() {
    if [ "$1" -gt 1000 ] && [ "$1" -lt 25000 ]; then
        REDSHIFT_TEMP=$1
        save_state
        redshift -P -O "$REDSHIFT_TEMP"
    fi
}

case $1 in
    toggle)
        if [ "$REDSHIFT" = on ]; then
            change_mode off
            redshift -x
        else
            change_mode on
            redshift -O "$REDSHIFT_TEMP"
        fi
        ;;
    increase)
        change_temp $((REDSHIFT_TEMP + changeValue))
        ;;
    decrease)
        change_temp $((REDSHIFT_TEMP - changeValue))
        ;;
    temperature)
        case $REDSHIFT in
            on)
                echo "${REDSHIFT_TEMP}K"
                ;;
            off)
                echo "off"
                ;;
        esac
        ;;
esac
