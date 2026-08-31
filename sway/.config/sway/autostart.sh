#!/bin/sh
# sway session autostart — ported from ~/.config/i3/autostart
# (nitrogen -> output bg in sway config, picom -> compositor built in,
#  parcellite -> cliphist in sway config, polybar -> waybar via bar {})

# skip the heavy bits during a nested smoke test
[ -n "$SWAY_SMOKE_TEST" ] && exit 0

# one-time audio level, as in the old i3 autostart
pactl set-sink-volume @DEFAULT_SINK@ 20%

# tray / daemons
/usr/libexec/polkit-mate-authentication-agent-1 &   # GUI password prompts for privileged actions
nm-applet --indicator &
# mate-power-manager removed: X11/MATE tool, GP-faults in libX11 under XWayland.
# logind handles power/lid keys; waybar's battery module shows charge.
dunst &
kdeconnect-indicator &          # phone pairing: clipboard, notifications, file share
[ -x "$HOME/.config/kdeconnect-autoopen.sh" ] && "$HOME/.config/kdeconnect-autoopen.sh" &   # auto-open KDE Connect files (HEIC->JPG); ships in the `hypr` stow package
udiskie --smart-tray --file-manager 'kitty --class yazi -e yazi' &   # auto-mount USB/SD; tray icon only when media present
~/.config/waybar/scripts/wattson-refresh.sh &   # nudge custom/wattson a few sec past each :00/:30 Agile boundary

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

# ws1: kitty running herdr, with Claude Code started in its first pane
swaymsg workspace number 1
~/.config/sway/herdr-claude.sh &
wait_for herdr

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
chromium --app='https://web.whatsapp.com/' &
wait_for 'chrome-web.whatsapp.com__-Default'

# start the session focused on the terminal
swaymsg workspace number 1
