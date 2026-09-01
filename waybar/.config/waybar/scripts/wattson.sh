#!/bin/sh
# waybar custom module: current Octopus Agile rate + solar generation today,
# from Wattson's household-energy endpoint (~/Dev/wattson).
#   (no arg)   waybar JSON {text,tooltip,class}; cache valid until the next
#              :00/:30 slot boundary (Agile rates change then)
#   --refresh  force a fetch, rewrite cache, print JSON
#   --report   force a fetch, print a human-readable breakdown (click popup)
#
# wattson-refresh.sh does a --refresh + `pkill -RTMIN+12 waybar` ~30s past each
# boundary; the waybar `interval` is only a slow fallback.
#
# Config (NOT tracked in dotfiles) — ~/.config/wattson/waybar.env, chmod 600:
#   WATTSON_API=https://api.askwattson.uk
#   WATTSON_TOKEN=<device token: web app Settings, or POST /devices/tokens>
#   WATTSON_HOUSEHOLD=<uuid from GET /households>
#
# One GET /households/{id}/energy returns .price.current_p (pence/kWh),
# .price.next_p, .price.average_p and .totals.solar_kwh + .current.solar_w.
#
#  = nf-fa-bolt (U+F0E7)    = nf-fa-sun (U+F185)

cfg="${XDG_CONFIG_HOME:-$HOME/.config}/wattson/waybar.env"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/wattson-energy.json"

BOLT=$(printf '\357\203\247')      # U+F0E7
SUN=$(printf '\357\206\205')       # U+F185

case "${1:-}" in
    --report|report)   mode=report ;;
    --refresh|refresh) mode=refresh ;;
    --data|data)       mode=data ;;    # compact JSON for the eww widget
    *)                 mode=bar ;;
esac

emit() { jq -cn --arg t "$1" --arg tt "$2" --arg c "$3" '{text:$t,tooltip:$tt,class:$c}'; }

[ -r "$cfg" ] || {
    [ "$mode" = report ] && { echo "No config at $cfg"; exit 0; }
    emit "$BOLT ?" "wattson: no config at $cfg" "error"; exit 0
}
. "$cfg"
: "${WATTSON_API:=https://api.askwattson.uk}"

data=""
if [ "$mode" = bar ] && [ -f "$cache" ]; then
    mtime=$(stat -c %Y "$cache" 2>/dev/null || echo 0)
    now=$(date +%s)
    # cache is good until the first :00/:30 boundary at or after it was written
    boundary=$(( mtime - (mtime % 1800) + 1800 ))
    [ "$now" -lt "$boundary" ] && data=$(cat "$cache")
fi

stale=""
if [ -z "$data" ]; then
    if [ -z "$WATTSON_TOKEN" ] || [ -z "$WATTSON_HOUSEHOLD" ]; then
        [ "$mode" = report ] && { echo "WATTSON_TOKEN / WATTSON_HOUSEHOLD not set in $cfg"; exit 0; }
        emit "$BOLT ?" "wattson: token/household not set in $cfg" "error"; exit 0
    fi
    resp=$(curl -sS --max-time 15 -w '\n%{http_code}' \
        "$WATTSON_API/households/$WATTSON_HOUSEHOLD/energy" \
        -H "Authorization: Bearer $WATTSON_TOKEN" 2>/dev/null)
    code=$(printf '%s\n' "$resp" | tail -n1)
    body=$(printf '%s\n' "$resp" | sed '$d')
    if [ "$code" = 200 ] && printf '%s' "$body" | jq -e . >/dev/null 2>&1; then
        data=$body; printf '%s\n' "$body" > "$cache"
    elif [ "$mode" = report ]; then
        echo "Fetch failed (HTTP ${code:-?})."; exit 0
    elif [ -f "$cache" ]; then
        data=$(cat "$cache"); stale=" (stale, HTTP ${code:-?})"
    else
        emit "$BOLT !" "wattson: fetch failed (HTTP ${code:-?})" "error"; exit 0
    fi
fi

get() { printf '%s' "$data" | jq -r "$1 // empty"; }
rate=$(get '.price.current_p')
next=$(get '.price.next_p')
avg=$(get '.price.average_p')
eff=$(get '.price.import_p_per_kwh')
solar_kwh=$(get '.totals.solar_kwh')
solar_w=$(get '.current.solar_w')
imp=$(get '.totals.imported_kwh')
exp=$(get '.totals.exported_kwh')
[ -n "$rate" ]      || rate=0
[ -n "$solar_kwh" ] || solar_kwh=0

f1() { awk -v x="${1:-0}" 'BEGIN{printf "%.1f", x}'; }

if [ "$mode" = data ]; then
    # reshape the cached /energy response for eww: scalars + a 48-point series
    # with per-slot bar height (0..1), colour band, and a "now" flag.
    printf '%s' "$data" | jq -c '
      def band($p): if $p<0 then "neg" elif $p<10 then "cheap"
                    elif $p<25 then "ok" elif $p<35 then "high" else "peak" end;
      (now|floor) as $nowsec
      | ([.tariff_slots[]? | {t:.slot_time, p:(.price_p|tonumber)}]) as $s
      | ($s | map(.p)) as $ps
      | (($ps|min) // 0) as $lo | (($ps|max) // 1) as $hi
      | {
          rate:  (.price.current_p // 0), next: (.price.next_p // 0),
          avg:   (.price.average_p // 0),  eff: (.price.import_p_per_kwh // 0),
          wk_avg:(.price.week_avg_import_p // 0),
          band:  band(.price.current_p // 0),
          solar_kwh:(.totals.solar_kwh // 0), solar_w:(.current.solar_w // 0),
          imported:(.totals.imported_kwh // 0), exported:(.totals.exported_kwh // 0),
          updated:(now|strftime("%H:%M")),
          slots: [ $s[] |
            (.t | fromdateiso8601) as $ts
            | { hh:(.t[11:16]),
                p:(.p*10|round/10),
                band:band(.p),
                h:(if $hi>$lo then ((.p-$lo)/($hi-$lo)) else 0.5 end),
                now:($nowsec>=$ts and $nowsec<$ts+1800) } ]
        }'
    exit 0
fi

if [ "$mode" = report ]; then
    printf 'Wattson \342\200\224 energy%s\n\n' "$stale"
    printf '  Agile rate   now  %sp/kWh    next  %sp/kWh\n' "$(f1 "$rate")" "$(f1 "$next")"
    printf '               today avg %sp   effective import %sp/kWh\n\n' "$(f1 "$avg")" "$(f1 "$eff")"
    printf '  Solar        today %s kWh    now %s W\n' "$(f1 "$solar_kwh")" "${solar_w:-?}"
    printf '  Grid         import %s kWh   export %s kWh\n\n' "$(f1 "$imp")" "$(f1 "$exp")"
    printf '  fetched  %s\n' "$(date '+%Y-%m-%d %H:%M:%S')"
    exit 0
fi

# colour by absolute Agile rate (p/kWh)
cls=$(awk -v r="$rate" 'BEGIN{
    if (r < 0)        print "neg";
    else if (r < 10)  print "cheap";
    else if (r < 25)  print "ok";
    else if (r < 35)  print "high";
    else              print "peak";
}')
[ -n "$stale" ] && cls=stale

text="$BOLT $(f1 "$rate")p  $SUN $(f1 "$solar_kwh")kWh"
tooltip=$(printf 'Agile now %sp/kWh  (next %sp, today avg %sp)\nSolar today %s kWh  (now %s W)\nGrid  import %s kWh  ·  export %s kWh%s' \
    "$(f1 "$rate")" "$(f1 "$next")" "$(f1 "$avg")" \
    "$(f1 "$solar_kwh")" "${solar_w:-?}" \
    "$(f1 "$imp")" "$(f1 "$exp")" "$stale")

emit "$text" "$tooltip" "$cls"
