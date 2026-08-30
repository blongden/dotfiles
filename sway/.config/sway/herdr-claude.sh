#!/bin/sh
# Launch kitty running herdr, then start Claude Code in herdr's first pane.
# Called from autostart.sh for the workspace-1 terminal.
set -eu

log=${XDG_CACHE_HOME:-$HOME/.cache}/herdr-claude.log
: > "$log"
say() { printf '%s  %s\n' "$(date +%H:%M:%S)" "$*" >> "$log"; }
say "start"

kitty --class herdr -e herdr &
say "kitty launched (pid $!)"

# wait for the herdr server socket to accept API calls
i=0
while [ "$i" -lt 100 ]; do
    herdr status server >/dev/null 2>&1 && break
    i=$((i + 1)); sleep 0.1
done
say "server ready after ${i}00ms"

# wait for the initial workspace's root pane to exist
pane=""
i=0
while [ "$i" -lt 100 ]; do
    pane=$(herdr pane list 2>/dev/null | jq -r '.result.panes[0].pane_id // empty')
    [ -n "$pane" ] && break
    i=$((i + 1)); sleep 0.1
done
if [ -z "$pane" ]; then say "no root pane after 10s, giving up"; exit 0; fi
say "root pane = $pane"

# don't stomp a pane that already has an agent running (e.g. herdr restored it)
agent=$(herdr pane list 2>/dev/null \
    | jq -r --arg p "$pane" '.result.panes[] | select(.pane_id==$p) | .agent // empty')
if [ -n "$agent" ]; then say "pane already hosts agent '$agent', nothing to do"; exit 0; fi

# agent start waits until the shell is ready and Claude is detected, then
# reports success only once Claude is ready for prompts. The trust dialog
# ("Do you trust the files in this folder?") blocks that readiness check, so
# ~/.claude.json must have projects["$HOME"].hasTrustDialogAccepted = true or
# this times out. Give it a generous window on a cold session.
#
# No pane-run fallback: firing `herdr pane run <pane> claude` after a timeout
# stacks a second claude on top of the one still sitting at a prompt, and the
# collision drops the pane back to bash. If agent start fails, leave the pane
# alone and let the log say why.
if herdr agent start main --kind claude --pane "$pane" --timeout 90000 >>"$log" 2>&1; then
    say "agent start ok"
else
    say "agent start failed (see above) — leaving pane at shell prompt"
fi
say "done"
