#!/bin/sh
# Poor-man's "rofi -show window" for sway: pick any window, jump to it.
# Bound to $mod+o.
sel=$(swaymsg -t get_tree | python3 -c '
import json, sys
def walk(n, ws=None):
    if n.get("type") == "workspace":
        ws = n.get("name")
    if n.get("name") and n.get("pid") and not n.get("nodes") and not n.get("floating_nodes"):
        app = n.get("app_id") or (n.get("window_properties") or {}).get("class") or "?"
        print(f'"'"'{n["id"]}\t[{ws}] {app}: {n["name"]}'"'"')
    for k in ("nodes", "floating_nodes"):
        for c in n.get(k, []):
            walk(c, ws)
walk(json.load(sys.stdin))' | wofi --dmenu --prompt "window" | cut -f1)

[ -n "$sel" ] && swaymsg "[con_id=$sel] focus"
