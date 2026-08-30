#!/bin/sh
# Toggle wofi: if an instance is already running, close it; otherwise launch
# it with the given arguments. Stops repeated keypresses stacking instances.
#   bindsym $mod+d exec ~/.config/sway/wofi-toggle.sh --show drun
pkill -x wofi && exit 0
exec wofi "$@"
