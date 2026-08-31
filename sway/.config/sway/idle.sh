#!/bin/sh
# swayidle wrapper. Run via `exec_always` so `swaymsg reload` re-applies any
# timeout changes (plain `exec` only fires at login). Kills any prior instance
# first so reloads don't stack swayidle processes.
pkill -x swayidle 2>/dev/null
# give the old one a moment to drop its inhibitors
sleep 0.3

exec swayidle -w \
    timeout 300  "$HOME/.config/screensaver/screensaver.sh start" \
    resume       "$HOME/.config/screensaver/screensaver.sh stop" \
    timeout 900  'swaymsg "output * power off"' \
    resume       'swaymsg "output * power on"'
