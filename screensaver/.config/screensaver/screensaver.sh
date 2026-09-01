#!/bin/bash
# Terminal screensaver — a fullscreen kitty running terminaltexteffects (tte)
# over BBS/Commodore-style ASCII art. Compositor-agnostic; driven by the idle
# daemon of whichever session is running:
#   sway:     ~/.config/sway/idle.sh    -> start @5min, stop on resume
#   Hyprland: ~/.config/hypr/hypridle.conf -> start @5min, NO on-resume (see below)
#
# Install the animation engine once:
#   sudo apt install pipx && pipx install terminaltexteffects
#
# Drop more art into ~/.config/screensaver/art/ (plain .txt, no ANSI colour).

art_dir="$HOME/.config/screensaver/art"
export PATH="$HOME/.local/bin:$PATH"

# CLOSING ON INPUT is the `loop` case's own job under Hyprland, NOT hypridle's.
# Mapping this fullscreen window makes Hyprland re-evaluate the pointer (internal
# simulateMouseMovement), which the idle protocol reports as activity ~1s later,
# every cycle. hypridle emits exactly one `resume` per idle period and that
# phantom eats it — so if hypridle's on-resume killed the screensaver it would
# die ~1s after every launch, and if it ignored the phantom the screensaver
# could never be killed by a later real resume (no second event). Omarchy hit
# the same wall ("screensaver resets idle timer" — its hypridle.conf). Fix:
# hypridle's 300s listener has NO on-resume; the loop below polls stdin itself
# (Omarchy's pattern — tte backgrounded, `read -t1` in 1s slices) and exits on
# any key OR mouse motion (?1003h/?1006h reporting, re-armed each frame). A 3s
# grace at launch swallows the phantom motion event kitty delivers when the
# window maps. An external `stop`/pkill still works via the signal trap.
# History: memory/idle-screensaver.md.
# swayidle (sway session) is unaffected — it still calls `stop` on resume.

# tte 0.15 effects that suit sparse BBS/Commodore art (verified names)
effects="beams binarypath blackhole burn decrypt errorcorrect expand \
laseretch matrix middleout orbittingvolley pour print rain randomsequence \
scattered slice slide swarm synthgrid unstable vhstape wipe"

case "${1:-}" in
  start)
    pgrep -f 'kitty --class screensaver' >/dev/null 2>&1 && exit 0
    # Background it and return immediately. swayidle runs with -w (wait for
    # command to finish), so a foreground kitty here blocks swayidle's event
    # loop — the `resume` handler (screensaver.sh stop) can then never fire and
    # the screensaver has to be closed by hand.
    kitty --class screensaver \
        -o background='#000000' \
        -o foreground='#33ff66' \
        -o cursor_blink_interval=0 \
        -o enable_audio_bell=no \
        -o confirm_os_window_close=0 \
        -o window_padding_width=24 \
        "$0" loop &
    ;;

  loop)
    tte_pid=""
    cleanup() {
        [ -n "$tte_pid" ] && kill "$tte_pid" 2>/dev/null
        printf '\033[?1003l\033[?1006l\033[?25h\033[2J\033[H'   # mouse off, cursor back, clear
    }
    trap cleanup EXIT
    trap 'cleanup; exit 0' INT TERM HUP QUIT   # external stop/pkill lands here

    # Grace window: the fullscreen window's map makes Hyprland re-evaluate the
    # pointer, and with mouse reporting on (below) kitty delivers that as a
    # motion escape ~1s in — i.e. the same phantom that plagued the hypridle
    # on-resume, now on our own stdin. Swallow any input for the first 3s so
    # the phantom doesn't self-dismiss the screensaver the instant it appears.
    started=$(date +%s)
    grace=3

    while :; do
        art=$(find -L "$art_dir" -type f -name '*.txt' | shuf -n1)   # -L: art files are stow symlinks
        [ -n "$art" ] || { sleep 5; continue; }
        eff=$(printf '%s\n' $effects | shuf -n1)
        clear
        # (re-)hide cursor + (re-)enable mouse-motion reporting (?1003 any-event,
        # ?1006 SGR) — tte resets terminal modes when each run exits.
        printf '\033[?25l\033[?1003h\033[?1006h'
        if command -v tte >/dev/null 2>&1; then
            tte --anchor-canvas c --anchor-text c "$eff" < "$art" 2>/dev/null &
            tte_pid=$!
            # Poll input in 1s slices WHILE tte animates (Omarchy pattern): read
            # never sits behind a foreground tte, so a keypress or mouse wiggle
            # dismisses within ~1s at any point. Any byte past the grace -> exit.
            while kill -0 "$tte_pid" 2>/dev/null; do
                if read -rsn1 -t 1 _; then
                    [ $(( $(date +%s) - started )) -lt "$grace" ] && continue
                    exit 0
                fi
            done
            tte_pid=""
        else
            cat "$art"
            if read -rsn1 -t 4 _; then
                [ $(( $(date +%s) - started )) -lt "$grace" ] && continue
                exit 0
            fi
        fi
    done
    ;;

  stop)
    pkill -f 'kitty --class screensaver' >/dev/null 2>&1 || true
    ;;

  *)
    echo "usage: $0 {start|stop}" >&2
    exit 1
    ;;
esac
