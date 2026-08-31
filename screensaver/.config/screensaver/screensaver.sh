#!/bin/sh
# Terminal screensaver — a fullscreen kitty running terminaltexteffects (tte)
# over BBS/Commodore-style ASCII art. Compositor-agnostic; driven by the idle
# daemon of whichever session is running:
#   sway:     ~/.config/sway/idle.sh   (swayidle)
#   Hyprland: ~/.config/hypr/hypridle.conf
# both call:  screensaver.sh start  (@5min)  /  screensaver.sh stop  (on resume)
#
# Install the animation engine once:
#   sudo apt install pipx && pipx install terminaltexteffects
#
# Drop more art into ~/.config/screensaver/art/ (plain .txt, no ANSI colour).

art_dir="$HOME/.config/screensaver/art"
export PATH="$HOME/.local/bin:$PATH"

# Debounce: launching the fullscreen kitty makes the compositor emit a pointer
# event (follow_mouse), which the idle daemon reads as "activity" and instantly
# fires `on-resume` -> stop, killing the screensaver ~1s after it appears. So
# `stop` ignores a resume that lands within GRACE seconds of a `start`.
stamp="${XDG_RUNTIME_DIR:-/tmp}/screensaver.started"
grace=2   # the spurious resume lands <1s after start; a returning human takes longer

# tte 0.15 effects that suit sparse BBS/Commodore art (verified names)
effects="beams binarypath blackhole burn decrypt errorcorrect expand \
laseretch matrix middleout orbittingvolley pour print rain randomsequence \
scattered slice slide swarm synthgrid unstable vhstape wipe"

case "${1:-}" in
  start)
    : > "$stamp"                                              # (re)arm the debounce
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
    # keep the cursor hidden; restore it if the loop is killed
    printf '\033[?25l'
    trap 'printf "\033[?25h\033[2J\033[H"' EXIT INT TERM
    while :; do
        art=$(find -L "$art_dir" -type f -name '*.txt' | shuf -n1)   # -L: art files are stow symlinks
        [ -n "$art" ] || { sleep 5; continue; }
        eff=$(printf '%s\n' $effects | shuf -n1)
        clear
        if command -v tte >/dev/null 2>&1; then
            tte --anchor-canvas c --anchor-text c "$eff" < "$art" 2>/dev/null \
                || cat "$art"
        else
            cat "$art"
        fi
        sleep 4
    done
    ;;

  stop)
    if [ -f "$stamp" ]; then
        age=$(( $(date +%s) - $(stat -c %Y "$stamp" 2>/dev/null || echo 0) ))
        [ "$age" -lt "$grace" ] && exit 0    # spurious resume right after start — ignore
    fi
    rm -f "$stamp"
    pkill -f 'kitty --class screensaver' >/dev/null 2>&1 || true
    ;;

  *)
    echo "usage: $0 {start|stop}" >&2
    exit 1
    ;;
esac
