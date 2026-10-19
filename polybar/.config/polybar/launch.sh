#!/usr/bin/env bash

# Basic script to kill all old bars and launch new.

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u "$UID" -x polybar > /dev/null; do sleep 1; done

# First monitor gets top+bottom bars, every additional monitor only gets the bottom bar
outputs=$(xrandr --query | grep " connected" | cut -d" " -f1)

first=1
for m in $outputs; do
    if [ "$first" -eq 1 ]; then
        MONITOR="$m" polybar -l=error -c ~/.config/polybar/config.ini top &
        MONITOR="$m" polybar -l=error -c ~/.config/polybar/config.ini bottom &
        first=0
    else
        MONITOR="$m" polybar -l=error -c ~/.config/polybar/config.ini bottom &
    fi
done

echo "Bars launched..."
