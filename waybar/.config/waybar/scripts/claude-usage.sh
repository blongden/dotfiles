#!/bin/sh
# waybar custom module: Claude (Claude Code) subscription usage.
#   (no arg)   print waybar JSON {text,tooltip,class}; reuses a short-lived cache
#   --refresh  force a fresh fetch, rewrite the cache, then print waybar JSON
#   --report   force a fresh fetch, then print a human-readable breakdown
#              (this is what the on-click kitty popup runs)
#
# Data source: GET https://api.anthropic.com/api/oauth/usage — the same endpoint
# the `/usage` slash command uses. Auth = the OAuth access token Claude Code
# stores in ~/.claude/.credentials.json (.claudeAiOauth.accessToken). Claude Code
# refreshes that token on disk itself; this script only reads it.
#
# The Claude subscription has NO calendar-month quota. The real limits are:
#   session = rolling 5-hour window   (.limits[] kind "session")
#   weekly  = rolling 7-day window    (.limits[] kind "weekly_all")
# "extra usage" = pay-as-you-go overage credits (shown in --report).
#
#  = nf-fa-robot (U+F544). Change ICON below for a different glyph.

cred="$HOME/.claude/.credentials.json"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/claude-usage.json"
ttl=120
endpoint="https://api.anthropic.com/api/oauth/usage"

ICON=$(printf '\357\225\204')      # U+F544  robot

case "${1:-}" in
    --report|report)   mode=report ;;
    --refresh|refresh) mode=refresh ;;
    *)                 mode=bar ;;
esac

emit() {   # emit <text> <tooltip> <class>
    jq -cn --arg t "$1" --arg tt "$2" --arg c "$3" \
        '{text:$t, tooltip:$tt, class:$c}'
}

# ── acquire data (cache unless forced / stale) ───────────────────────────
data=""
stale=""

if [ "$mode" = "bar" ] && [ -f "$cache" ]; then
    age=$(( $(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || echo 0) ))
    [ "$age" -lt "$ttl" ] && data=$(cat "$cache")
fi

if [ -z "$data" ]; then
    token=$(jq -r '.claudeAiOauth.accessToken // empty' "$cred" 2>/dev/null)
    if [ -z "$token" ]; then
        [ "$mode" = "report" ] && { echo "No Claude credentials at $cred"; exit 0; }
        emit "$ICON ?" "Claude usage: no credentials at $cred" "error"; exit 0
    fi
    resp=$(curl -sS --max-time 10 -w '\n%{http_code}' "$endpoint" \
        -H "Authorization: Bearer $token" \
        -H "anthropic-beta: oauth-2025-04-20" 2>/dev/null)
    code=$(printf '%s\n' "$resp" | tail -n1)
    body=$(printf '%s\n' "$resp" | sed '$d')
    if [ "$code" = "200" ] && printf '%s' "$body" | jq -e . >/dev/null 2>&1; then
        data=$body
        printf '%s\n' "$body" > "$cache"
    elif [ "$mode" = "report" ]; then
        echo "Fetch failed (HTTP ${code:-?})."
        [ "$code" = "401" ] && echo "Token likely expired — run any 'claude' command to refresh it, then retry."
        exit 0
    elif [ -f "$cache" ]; then
        data=$(cat "$cache"); stale=" (stale, HTTP ${code:-?})"
    else
        emit "$ICON !" "Claude usage: fetch failed (HTTP ${code:-?})" "error"; exit 0
    fi
fi

# ── parse ───────────────────────────────────────────────────────────────
get() { printf '%s' "$data" | jq -r "$1"; }

sess=$(get '((.limits[]? | select(.kind=="session")     | .percent) // .five_hour.utilization // 0) | floor')
week=$(get '((.limits[]? | select(.kind=="weekly_all")  | .percent) // .seven_day.utilization // 0) | floor')
sess_reset=$(get '(.limits[]? | select(.kind=="session")    | .resets_at) // .five_hour.resets_at // empty')
week_reset=$(get '(.limits[]? | select(.kind=="weekly_all") | .resets_at) // .seven_day.resets_at // empty')
sev=$(get '[.limits[]?.severity] as $s
           | if ($s | any(. == "critical")) then "critical"
             elif ($s | any(. == "warning")) then "warning"
             else "normal" end')
xu_enabled=$(get '.extra_usage.is_enabled // false')
spend_minor=$(get '.spend.used.amount_minor // 0')
spend_cur=$(get '.spend.used.currency // .extra_usage.currency // "USD"')
spend_exp=$(get '.spend.used.exponent // 2')

sym=$(case "$spend_cur" in GBP) printf '\302\243';; USD) echo '$';; EUR) printf '\342\202\254';; *) echo "$spend_cur ";; esac)
money=$(awk -v m="$spend_minor" -v e="$spend_exp" 'BEGIN{ printf "%.*f", e, m/(10^e) }')

# reset-time helpers (GNU date)
at()  { [ -n "$1" ] && date -d "$1" '+%a %H:%M' 2>/dev/null || printf '?'; }
rel() {
    [ -n "$1" ] || { printf ''; return; }
    tgt=$(date -d "$1" +%s 2>/dev/null) || { printf ''; return; }
    d=$(( tgt - $(date +%s) ))
    [ "$d" -le 0 ] && { printf 'due'; return; }
    h=$(( d / 3600 )); m=$(( (d % 3600) / 60 ))
    if   [ "$h" -ge 24 ]; then printf '%dd %dh' $(( h / 24 )) $(( h % 24 ))
    elif [ "$h" -ge 1 ];  then printf '%dh %dm' "$h" "$m"
    else printf '%dm' "$m"; fi
}

# ── --report: full breakdown for the popup ──────────────────────────────
if [ "$mode" = "report" ]; then
    bar() {
        p=${1:-0}; f=$(( (p + 5) / 10 )); [ "$f" -gt 10 ] && f=10; [ "$f" -lt 0 ] && f=0
        i=0; s=''
        while [ "$i" -lt 10 ]; do [ "$i" -lt "$f" ] && s="${s}#" || s="${s}-"; i=$(( i + 1 )); done
        printf '[%s]' "$s"
    }
    printf 'Claude Code \342\200\224 usage\n\n'
    printf '  Session (5-hour)   %s  %3d%%\n'  "$(bar "$sess")" "$sess"
    printf '    resets  %s  (in %s)\n\n'       "$(at "$sess_reset")" "$(rel "$sess_reset")"
    printf '  Weekly  (7-day)    %s  %3d%%\n'  "$(bar "$week")" "$week"
    printf '    resets  %s  (in %s)\n\n'       "$(at "$week_reset")" "$(rel "$week_reset")"
    if [ "$xu_enabled" = "true" ]; then
        printf '  Extra usage       enabled \302\267 %s%s used\n' "$sym" "$money"
    else
        printf '  Extra usage       off\n'
    fi
    printf '\n  fetched  %s%s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$stale"
    exit 0
fi

# ── bar output ─────────────────────────────────────────────────────────
case "$sev" in
    critical) cls=critical ;;
    warning)  cls=warn ;;
    *)  if   [ "$sess" -ge 90 ] || [ "$week" -ge 90 ]; then cls=critical
        elif [ "$sess" -ge 75 ] || [ "$week" -ge 75 ]; then cls=warn
        else cls=ok; fi ;;
esac
[ -n "$stale" ] && cls=stale

text="$ICON ${sess}% / ${week}%"
tooltip=$(printf 'Claude \302\267 subscription usage%s\n\nSession (5h)  %3d%%   resets %s  (%s)\nWeekly  (7d)  %3d%%   resets %s  (%s)\nExtra usage   %s%s used\n\nupdated %s' \
    "$stale" \
    "$sess" "$(at "$sess_reset")" "$(rel "$sess_reset")" \
    "$week" "$(at "$week_reset")" "$(rel "$week_reset")" \
    "$sym" "$money" \
    "$(date '+%H:%M:%S')")

emit "$text" "$tooltip" "$cls"
