#!/usr/bin/env sh

# Basic script to kill all old bars and launch new.

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done

# Detect if secondary monitor is connected, if so, add a specific bar and move tray to it
# Else, keep tray on main monitor
# see https://github.com/polybar/polybar/issues/763

outputs=$(xrandr --query | grep " connected" | cut -d" " -f1)
set -- $outputs
tray_output=$1

for m in $outputs; do
    if [ $m == $1 ]; then
        MONITOR=$m polybar -l=error -c ~/.config/polybar/config.ini top &
        MONITOR=$m polybar -l=error -c ~/.config/polybar/config.ini bottom &
    elif [ $m == $2 ]; then
        tray_output=$m
        MONITOR=$m polybar -l=error -c ~/.config/polybar/config.ini bottom &
    else
        MONITOR=$m polybar -l=error -c ~/.config/polybar/config.ini bottom &
    fi
done

echo "Bars launched..."
