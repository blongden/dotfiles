#!/bin/sh
# sway session autostart — ported from ~/.config/i3/autostart
# (nitrogen -> output bg in sway config, picom -> compositor built in,
#  parcellite -> cliphist in sway config, polybar -> waybar via bar {})

# skip the heavy bits during a nested smoke test
[ -n "$SWAY_SMOKE_TEST" ] && exit 0

# one-time audio level, as in the old i3 autostart
pactl set-sink-volume @DEFAULT_SINK@ 20%

# tray / daemons
nm-applet --indicator &
mate-power-manager &
dunst &

# Optional warm night tint (you didn't run redshift before, so off by default).
# Enable by editing ~/.config/gammastep/config.ini and uncommenting:
# gammastep &

# terminals + browser — placed on their workspaces at login only.
# No persistent 'assign' rules, so $mod+Return / $mod+Shift+Return open
# kitty / the browser on whatever workspace is focused.
wait_for() { for _ in $(seq 1 100); do
    swaymsg -t get_tree | grep -q "\"app_id\": \"$1\"" && return
    sleep 0.1
done; }

kitty --class scratchpad &

swaymsg workspace number 1
kitty &
wait_for kitty

swaymsg workspace number 2
chromium &
wait_for chromium

# ws3: Discord + Proton Mail as Chromium app windows, stacked (see config
# for the matching 'assign' + 'layout stacking' rules).
swaymsg workspace number 3
chromium --app='https://discord.com/app' &
wait_for 'chrome-discord.com__app-Default'
swaymsg layout stacking
chromium --app='https://mail.proton.me/' &
wait_for 'chrome-mail.proton.me__-Default'

# start the session focused on the terminal
swaymsg workspace number 1
