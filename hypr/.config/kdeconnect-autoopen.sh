#!/bin/sh
# Watch KDE Connect for incoming files and open each one automatically.
#
# Subscribes to the D-Bus signal
#   org.kde.kdeconnect.device.share.shareReceived   (arg: local file path)
# which fires once per completed incoming transfer. Compositor-agnostic —
# autostarted from both hyprland.lua and ~/.config/sway/autostart.sh.
#
# HEIC/HEIF handling — $KDECONNECT_HEIC (default "convert"):
#   convert : `heic2img save jpg` to a sibling .jpg (original kept), open the .jpg
#   view    : open the .heic as-is (both viewers load it via libheif/gdk-pixbuf)
#
# Image viewer — $KDECONNECT_VIEWER (default "swappy"):
#   swappy  : annotate + "Copy to clipboard" (Ctrl+C) + save (Ctrl+S)
#   swayimg : plain viewer with zoom/pan/gallery
# Anything that isn't an image opens via xdg-open.
# Debug log: ~/.cache/kdeconnect-autoopen.log

heic_mode=${KDECONNECT_HEIC:-convert}
viewer=${KDECONNECT_VIEWER:-swappy}
logf="${XDG_CACHE_HOME:-$HOME/.cache}/kdeconnect-autoopen.log"

log() { printf '%s  %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$logf"; }

# single instance (+ pidfile so a supervisor can stop us without pgrep guesswork)
run="${XDG_RUNTIME_DIR:-/tmp}"
exec 9>"$run/kdeconnect-autoopen.lock"
flock -n 9 || { log "already running — exit"; exit 0; }
echo $$ > "$run/kdeconnect-autoopen.pid"
trap 'rm -f "$run/kdeconnect-autoopen.pid"' EXIT

view() {   # open an image file in the configured viewer
    log "view ($viewer): $1"
    notify-send -a "KDE Connect" "Opening image" "$(basename "$1")"
    case $viewer in
        swappy) setsid -f swappy -f "$1" >/dev/null 2>&1 ;;
        *)      setsid -f "$viewer" "$1" >/dev/null 2>&1 ;;
    esac
}

handle() {
    f=$1
    [ -f "$f" ] || { log "not a regular file, skipping: $f"; return; }
    lc=$(printf '%s' "$f" | tr '[:upper:]' '[:lower:]')
    case $lc in
        *.heic|*.heif)
            if [ "$heic_mode" = "convert" ]; then
                jpg="${f%.*}.jpg"
                if heic2img save jpg "$f" >/dev/null 2>&1 && [ -f "$jpg" ]; then
                    log "heic2img -> $jpg"
                    view "$jpg"
                else
                    log "heic2img FAILED, opening original: $f"
                    view "$f"
                fi
            else
                view "$f"
            fi
            ;;
        *.jpg|*.jpeg|*.png|*.gif|*.webp|*.bmp|*.tif|*.tiff|*.avif|*.qoi|*.ppm)
            view "$f" ;;
        *)
            log "xdg-open: $f"
            notify-send -a "KDE Connect" "File received" "$(basename "$f")"
            setsid -f xdg-open "$f" >/dev/null 2>&1 ;;
    esac
}

log "started (heic_mode=$heic_mode) — watching for shareReceived"

# dbus-monitor with an interface/member match rule: reliable, sender-agnostic
# (so `dbus-send` self-tests are caught too), no --dest needed. Each matching
# signal prints two lines:
#   signal ... interface=org.kde.kdeconnect.device.share; member=shareReceived
#      string "/home/ben/Downloads/IMG_0001.HEIC"
dbus-monitor --session \
    "type='signal',interface='org.kde.kdeconnect.device.share',member='shareReceived'" \
    2>/dev/null | while read -r line; do
    case $line in
        *"member=shareReceived"*) : ;;
        *) continue ;;
    esac
    read -r payload || break            # the following `string "..."` line
    path=${payload#*\"}
    path=${path%\"*}
    path=${path#file://}
    [ -n "$path" ] || continue
    log "shareReceived: $path"
    handle "$path"
done
