#!/bin/sh
# Boundary-aligned refresh for the waybar custom/wattson module.
#
# Octopus Agile rates change on the hour and half-hour. This sleeps until ~30s
# past the next :00/:30 (giving Wattson's server-side price roll time to land),
# forces wattson.sh to re-fetch, and signals waybar to redraw. The module's
# `interval` in the waybar config is only a slow fallback for when this isn't
# running.
#
# Autostarted (guarded) from hyprland.lua and ~/.config/sway/autostart.sh.
# Single-instance via flock; stop it by killing the pid in
# $XDG_RUNTIME_DIR/wattson-refresh.pid.

grace=30           # seconds past the boundary before fetching (server roll lag)
signal=12          # waybar `signal` for custom/wattson  -> SIGRTMIN+12
script="$(dirname "$0")/wattson.sh"

run="${XDG_RUNTIME_DIR:-/tmp}"
exec 9>"$run/wattson-refresh.lock"
flock -n 9 || exit 0
echo $$ > "$run/wattson-refresh.pid"
trap 'rm -f "$run/wattson-refresh.pid"' EXIT

while :; do
    now=$(date +%s)
    # seconds until the next half-hour boundary, plus the grace period
    sleep $(( 1800 - (now % 1800) + grace ))
    "$script" --refresh >/dev/null 2>&1
    pkill -RTMIN+"$signal" waybar 2>/dev/null || true
done
