#!/bin/sh
# Searchable cheatsheet of the live sway keybindings, shown in wofi.
# Reads `swaymsg -t get_config` so it always reflects what's actually loaded
# (main config + /etc/sway/config.d/*), then expands $variables and prettifies
# modifier names. Enter just closes; nothing is executed.
#
# Launcher entry: ~/.local/share/applications/sway-keybindings.desktop
# Optional key:   bindsym $mod+slash exec ~/.config/sway/keybinds.sh

swaymsg -t get_config | python3 -c '
import json, re, sys

cfg = json.load(sys.stdin)["config"]
Q = chr(34)

# ---- collect `set $var value` ---------------------------------------------
vars = {}
for line in cfg.splitlines():
    m = re.match(r"\s*set\s+(\$[\w-]+)\s+(.*)", line)
    if m:
        vars[m.group(1)] = m.group(2).strip()

def expand(s):
    for _ in range(5):
        new = re.sub(r"\$[\w-]+", lambda m: vars.get(m.group(0), m.group(0)), s)
        if new == s:
            break
        s = new
    return s

MODMAP = {"mod1": "Alt", "mod4": "Super", "mod3": "Hyper", "mod2": "Mod2",
          "control": "Ctrl", "ctrl": "Ctrl", "shift": "Shift"}

def pretty_keys(spec):
    return "+".join(MODMAP.get(p.lower(), p) for p in spec.split("+"))

def mode_label(tok):
    tok = tok.strip().strip(Q).strip()
    if tok.startswith("$"):
        tok = re.sub(r"^\$(mode[_-]?)?", "", tok)
    return tok or "mode"

# ---- walk config, tracking mode blocks ----------------------------------
rows, mode_stack = [], []
for raw in cfg.splitlines():
    line = raw.strip()
    if not line or line.startswith("#"):
        continue

    mopen = re.match(r"mode\s+(?:--pango_markup\s+)?" + Q + "?([^" + Q + "{]+)" + Q + r"?\s*{", line)
    if mopen:
        mode_stack.append(mode_label(mopen.group(1)))
        continue
    if line == "}" and mode_stack:
        mode_stack.pop()
        continue

    b = re.match(r"(bindsym|bindcode)\s+(.*)", line)
    if not b:
        continue
    rest = b.group(2)
    while rest.startswith("--"):
        rest = rest.split(None, 1)[1] if " " in rest else ""
    if not rest:
        continue
    keyspec, _, command = rest.partition(" ")
    keys = pretty_keys(expand(keyspec))
    cmd = expand(command).strip()
    cmd = re.sub(r",\s*mode\s+.default.\s*$", "", cmd)

    prefix = ("[" + "/".join(mode_stack) + "] ") if mode_stack else ""
    rows.append((prefix, keys, cmd))

kw = max((len(p + k) for p, k, _ in rows), default=10)
for p, k, c in rows:
    print(f"{p}{k:<{kw - len(p)}}   {c}")
' | wofi --dmenu --prompt "sway keys" \
        --width 62% --height 72% --lines 20 \
        --cache-file /dev/null --insensitive -D matching=fuzzy \
  >/dev/null 2>&1 || true
