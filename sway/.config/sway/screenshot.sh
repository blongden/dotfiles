#!/bin/sh
# grim + slurp + wl-copy — replaces maim/xdotool/xclip.
# The *-edit modes pipe the grab into swappy for annotation before it lands.
# Usage: screenshot.sh {full|window|region|full-clip|window-clip|region-clip
#                       |full-edit|window-edit|region-edit}

dir="$HOME/Pictures"
ts=$(date -u +'%Y%m%d-%H%M%SZ')

# geometry of the currently focused window (for the "window" modes)
focused_geom() {
    if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
        hyprctl activewindow -j | \
            jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'
        return
    fi
    swaymsg -t get_tree | \
        python3 -c 'import json,sys
def walk(n):
    if n.get("focused"): return n["rect"]
    for k in ("nodes","floating_nodes"):
        for c in n.get(k,[]):
            r=walk(c)
            if r: return r
r=walk(json.load(sys.stdin))
print(f"{r[\"x\"]},{r[\"y\"]} {r[\"width\"]}x{r[\"height\"]}")'
}

# grim geometry for the given mode, on stdout ("" means whole output)
geom_for() {
    case "$1" in
        full*)   echo "" ;;
        region*) slurp ;;
        window*) focused_geom ;;
    esac
}

# open swappy on stdin; on exit it writes the annotated result to $1.
# Use the toolbar Copy button (or Ctrl+C) to put it on the clipboard.
edit() {
    swappy -f - -o "$1"
}

case "$1" in
    full)        grim "$dir/screenshot-$ts-all.png" ;;
    region)      grim -g "$(slurp)" "$dir/screenshot-$ts-selected.png" ;;
    window)      grim -g "$(focused_geom)" "$dir/screenshot-$ts-current.png" ;;
    full-clip)   grim - | wl-copy ;;
    region-clip) grim -g "$(slurp)" - | wl-copy ;;
    window-clip) grim -g "$(focused_geom)" - | wl-copy ;;
    full-edit)   grim - | edit "$dir/screenshot-$ts-edit.png" ;;
    region-edit) g=$(slurp) || exit 1; grim -g "$g" - | edit "$dir/screenshot-$ts-edit.png" ;;
    window-edit) grim -g "$(focused_geom)" - | edit "$dir/screenshot-$ts-edit.png" ;;
    *) echo "usage: $0 {full|window|region}[-clip|-edit]" >&2; exit 1 ;;
esac

case "$1" in
    *-edit) : ;;  # satty shows its own toast on copy/save
    *-clip) notify-send "Screenshot" "Copied to clipboard" ;;
    *)      notify-send "Screenshot" "Saved to $dir" ;;
esac
