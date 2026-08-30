#!/bin/sh
# waybar custom module: Tailscale connection state.
#   (no arg)      print JSON {text,tooltip,class} for the bar
#   toggle-exit   flip the exit node between $exit_node and off, then refresh
#
# Exit node defaults to "homeassistant"; override with $TAILSCALE_EXIT_NODE.
# Needs `tailscale set --operator=$USER` to have been run once (it has).

exit_node=${TAILSCALE_EXIT_NODE:-homeassistant}

# Font Awesome 6 Free glyphs, as octal UTF-8 so this file stays ASCII.
ICON_LOCK=$(printf '\357\200\243')    # U+F023  lock       -> connected
ICON_GLOBE=$(printf '\357\202\254')   # U+F0AC  globe      -> via exit node
ICON_OPEN=$(printf '\357\202\234')    # U+F09C  unlock     -> offline / logged out

j=$(tailscale status --json 2>/dev/null) || {
    jq -cn --arg i "$ICON_OPEN" '{text:$i, tooltip:"tailscale: daemon not responding", class:"offline"}'
    exit 0
}

state=$(printf '%s' "$j" | jq -r '.BackendState')

case "$state" in
    Running) : ;;
    NeedsLogin|NoState)
        jq -cn --arg i "$ICON_OPEN" '{text:$i, tooltip:"tailscale: logged out", class:"offline"}'
        exit 0 ;;
    Stopped)
        jq -cn --arg i "$ICON_OPEN" '{text:$i, tooltip:"tailscale: stopped (tailscale up)", class:"offline"}'
        exit 0 ;;
    *)
        jq -cn --arg i "$ICON_OPEN" --arg s "$state" '{text:$i, tooltip:("tailscale: " + $s), class:"offline"}'
        exit 0 ;;
esac

# --- toggle-exit action -------------------------------------------------
if [ "${1:-}" = "toggle-exit" ]; then
    using=$(printf '%s' "$j" | jq -r 'if (.ExitNodeStatus // empty) then "yes" else "no" end')
    if [ "$using" = "yes" ]; then
        tailscale set --exit-node=
    else
        tailscale set --exit-node="$exit_node" --exit-node-allow-lan-access=true
    fi
    pkill -RTMIN+10 waybar
    exit 0
fi

# --- status render ----------------------------------------------------
self_ip=$(printf '%s' "$j" | jq -r '.TailscaleIPs[0] // .Self.TailscaleIPs[0] // "?"')
suffix=$(printf '%s'  "$j" | jq -r '.MagicDNSSuffix // ""')
peers_online=$(printf '%s' "$j" | jq -r '[.Peer[]? | select(.Online)] | length')
peers_total=$(printf '%s'  "$j" | jq -r '(.Peer // {}) | length')

exit_name=$(printf '%s' "$j" | jq -r '
    (.Peer // {}) | to_entries
    | map(select(.value.ExitNode == true)) | .[0].value.HostName // ""')

if [ -n "$exit_name" ]; then
    cls="exit-node"
    text="$ICON_GLOBE $exit_name"
    line1="exit node: $exit_name"
else
    cls="connected"
    text="$ICON_LOCK"
    line1="connected"
fi

tooltip=$(printf '%s\n%s  ·  %s\npeers: %s/%s online' \
    "$line1" "$self_ip" "${suffix:-no MagicDNS}" "$peers_online" "$peers_total")

jq -cn --arg text "$text" --arg tt "$tooltip" --arg cls "$cls" \
    '{text: $text, tooltip: $tt, class: $cls}'
