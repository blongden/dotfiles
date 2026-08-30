#!/bin/sh
# Push-to-talk dictation: toggle. First press starts recording from the mic;
# second press stops, transcribes locally with whisper.cpp, and types the text
# into the focused window via wtype.
#
#   bindsym $mod+grave exec ~/.config/sway/dictate.sh
#
# Deps: whisper.cpp (whisper-cli), wtype, pipewire (pw-record), libnotify.
# Model: ~/.local/share/whisper/ggml-<name>.bin  — small.en is the default;
#        drop to base.en for lower latency, bump to medium.en for accuracy.

model="${WHISPER_MODEL:-$HOME/.local/share/whisper/ggml-small.en.bin}"
wav="${XDG_RUNTIME_DIR:-/tmp}/dictate.wav"
pidf="${XDG_RUNTIME_DIR:-/tmp}/dictate.pid"

notify() { notify-send -a dictate -t "${2:-2000}" "$1"; }

# ---- stop branch: a recording is in progress ----
if [ -f "$pidf" ] && kill -0 "$(cat "$pidf")" 2>/dev/null; then
    kill "$(cat "$pidf")" 2>/dev/null
    rm -f "$pidf"
    # let pw-record flush the WAV header
    sleep 0.2
    notify "  transcribing…" 1500

    text=$(whisper-cli -m "$model" -f "$wav" -l en -nt -np -otxt -of "$wav" 2>/dev/null; cat "$wav.txt" 2>/dev/null)
    rm -f "$wav" "$wav.txt"

    # tidy: collapse whitespace, trim
    text=$(printf '%s' "$text" | tr '\n' ' ' | sed -e 's/  */ /g' -e 's/^ *//' -e 's/ *$//')
    # drop whisper's non-speech placeholders when they're the whole output:
    # [BLANK_AUDIO], (wind blowing), *music*, etc.
    if [ -z "$text" ] || printf '%s' "$text" | grep -Eq '^(\[[^]]*\]|\([^)]*\)|\*[^*]*\*)$'; then
        notify "  nothing heard"
        exit 0
    fi
    wtype -- "$text"
    exit 0
fi

# ---- start branch ----
command -v whisper-cli >/dev/null || { notify "dictate: whisper-cli missing"; exit 1; }
command -v wtype       >/dev/null || { notify "dictate: wtype missing";       exit 1; }
[ -f "$model" ] || { notify "dictate: model not found\n$model"; exit 1; }

# 16 kHz mono s16 is what whisper wants — record straight to that
pw-record --rate 16000 --channels 1 --format s16 "$wav" &
echo $! > "$pidf"
notify "🎙  listening — press again to stop" 60000
