#!/bin/sh
# Screenshot picker for wofi. Reached from the launcher via
# ~/.local/share/applications/screenshot.desktop, or bind a key in sway:
#   bindsym Print exec ~/.config/sway/screenshot-menu.sh
shot="$HOME/.config/sway/screenshot.sh"

sel=$(printf '%s\n' \
    "Region  —  copy to clipboard|region-clip" \
    "Region  —  annotate|region-edit" \
    "Region  —  save to file|region" \
    "Window  —  copy to clipboard|window-clip" \
    "Window  —  annotate|window-edit" \
    "Window  —  save to file|window" \
    "Full    —  copy to clipboard|full-clip" \
    "Full    —  annotate|full-edit" \
    "Full    —  save to file|full" \
  | wofi --dmenu --prompt "Screenshot" --width 420 --height 380 \
         --lines 9 --cache-file /dev/null \
  | cut -d'|' -f2)

[ -n "$sel" ] || exit 0

# let wofi fully close so it isn't caught in the frame
sleep 0.25
exec "$shot" "$sel"
